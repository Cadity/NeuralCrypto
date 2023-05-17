using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Org.BouncyCastle.Bcpg;
using Org.BouncyCastle.Bcpg.OpenPgp;
using Org.BouncyCastle.Crypto;
using Org.BouncyCastle.Crypto.Parameters;
using Org.BouncyCastle.Math;
using Org.BouncyCastle.Security;

namespace CryptoEngine.OpenPGP
{
    public class PGPKeyGen
    {
        private PGPKeyParameters parameters { get; }
        private PgpKeyRingGenerator keyRingGenerator { get; set; }

        public PGPKeyGen(PGPKeyParameters keyParameters)
        {
            parameters = keyParameters;
            keyRingGenerator = null;
            Get_Key_Ring();
        }

        public List<string> Get_Keys()
        {
            if (keyRingGenerator == null)
                throw new Exception("KeyRingGenerator is null");

            PgpSecretKeyRing secretKey = keyRingGenerator.GenerateSecretKeyRing();
            PgpPublicKeyRing publicKey = keyRingGenerator.GeneratePublicKeyRing();

            string publicKeyArmored, secretKeyArmored = "";

            using (MemoryStream memStream = new MemoryStream())
            {
                using (ArmoredOutputStream armoredStream = new ArmoredOutputStream(memStream))
                {
                    secretKey.Encode(armoredStream);
                    armoredStream.Close();
                    secretKeyArmored = Encoding.ASCII.GetString(memStream.ToArray());
                }
            }

            using (MemoryStream memStream = new MemoryStream())
            {
                using (ArmoredOutputStream armoredStream = new ArmoredOutputStream(memStream))
                {
                    publicKey.Encode(armoredStream);
                    armoredStream.Close();
                    publicKeyArmored = Encoding.ASCII.GetString(memStream.ToArray());
                }
            }

            var keys = new List<string>();

            string pattern = @"Version:\s*(.*)\s*";
            string replacement = "Version: NeuralCrypto App\n\n";

            keys.Add(Regex.Replace(publicKeyArmored, pattern, replacement));
            keys.Add(Regex.Replace(secretKeyArmored, pattern, replacement));

            return keys;
        }

        private void Get_Key_Ring()
        {
            if (NeuralCryptoParameters.RSA_AuthorisedAlgorithmeType.Contains(parameters.algorithm))
                Get_RSA_Key_Ring_Generator();
            else return;
        }

        private void Get_RSA_Key_Ring_Generator()
        {
            if (parameters.keySize < 2048 || parameters.keySize > 4096)
                throw new Exception("Invalid key size for RSA");

            if (!(NeuralCryptoParameters.RSA_AuthorisedAlgorithmeType.Contains(parameters.algorithm)))
                throw new Exception("Wrong Algorithm type for RSA");

            RsaKeyGenerationParameters rsaParams = new RsaKeyGenerationParameters(
            BigInteger.ValueOf(0x10001),
            new SecureRandom(),
            parameters.keySize,
            12);

            IAsymmetricCipherKeyPairGenerator generator
                = GeneratorUtilities.GetKeyPairGenerator("RSA");
            generator.Init(rsaParams);

            PgpKeyPair masterKeyPair = new PgpKeyPair(
                parameters.algorithm,
                generator.GenerateKeyPair(),
                DateTime.UtcNow);

            PgpSignatureSubpacketGenerator masterSubpckGen
                = new PgpSignatureSubpacketGenerator();
            masterSubpckGen.SetKeyFlags(false, PgpKeyFlags.CanSign
                | PgpKeyFlags.CanCertify);
            masterSubpckGen.SetPreferredSymmetricAlgorithms(false,
                (from a in NeuralCryptoParameters.SymetricAlgorithmTag
                 select (int)a).ToArray());
            masterSubpckGen.SetPreferredHashAlgorithms(false,
                (from a in NeuralCryptoParameters.RSA_HashAlgorithmTag
                 select (int)a).ToArray());

            if (parameters.secondsValidity > 0)
                masterSubpckGen.SetKeyExpirationTime(true, parameters.secondsValidity);

            PgpKeyPair encKeyPair = new PgpKeyPair(
                parameters.algorithm,
                generator.GenerateKeyPair(),
                DateTime.UtcNow);

            PgpSignatureSubpacketGenerator encSubpckGen = new PgpSignatureSubpacketGenerator();
            encSubpckGen.SetKeyFlags(false, PgpKeyFlags.CanEncryptCommunications | PgpKeyFlags.CanEncryptStorage);

            masterSubpckGen.SetPreferredSymmetricAlgorithms(false,
                (from a in NeuralCryptoParameters.SymetricAlgorithmTag
                 select (int)a).ToArray());
            masterSubpckGen.SetPreferredHashAlgorithms(false,
                (from a in NeuralCryptoParameters.RSA_HashAlgorithmTag
                 select (int)a).ToArray());

            PgpKeyRingGenerator keyRingGen = new PgpKeyRingGenerator(
                PgpSignature.DefaultCertification,
                masterKeyPair,
                parameters.identity,
                SymmetricKeyAlgorithmTag.Aes256,
                parameters.keyPassword.ToCharArray(),
                true,
                masterSubpckGen.Generate(),
                null,
                new SecureRandom());

            keyRingGen.AddSubKey(encKeyPair, encSubpckGen.Generate(), null);

            keyRingGenerator = keyRingGen;
        }
    }

    public class PGPKeyParameters
    {
        public string identity { get; }
        public DateTime expirationDate { get; }
        public int keySize { get; }
        public PublicKeyAlgorithmTag algorithm { get; }
        public string keyPassword { get; }
        public long secondsValidity { get; }

        public PGPKeyParameters(string username, string usermail, string usercomment, int size, string password, DateTime keyExpirationDate, PublicKeyAlgorithmTag keyAlgorithm)
        {
            identity = GetIdentity(username, usermail, usercomment);
            expirationDate = keyExpirationDate;
            keySize = (size <= 0) ? throw new Exception("Size can't be lower than 0") : size;
            algorithm = keyAlgorithm;
            keyPassword = string.IsNullOrEmpty(password) ? throw new Exception("Password can't be null or empty") : password;
            secondsValidity = (long)(expirationDate - DateTime.UtcNow).TotalSeconds;
        }

        private string GetIdentity(string name, string email, string comment)
        {
            if (string.IsNullOrEmpty(name) == true)
                throw new Exception("Username can't be null or empty");

            if ((email == "" || email == null) && (comment == "" || comment == null))
            {
                return name;
            }
            if ((email != "" || email != null) && (comment == "" || comment == null))
            {
                return name + " <" + email + ">";
            }
            if ((email == "" || email == null) && (comment != "" || comment != null))
            {
                return name + " (" + comment + ")";
            }
            return name + " (" + comment + ") <" + email + ">";
        }
    }

    public static class NeuralCryptoParameters
    {
        public static readonly List<PublicKeyAlgorithmTag> RSA_AuthorisedAlgorithmeType = new List<PublicKeyAlgorithmTag>() { PublicKeyAlgorithmTag.RsaGeneral, PublicKeyAlgorithmTag.RsaSign };
        public static readonly SymmetricKeyAlgorithmTag[] SymetricAlgorithmTag = new SymmetricKeyAlgorithmTag[] { SymmetricKeyAlgorithmTag.Aes256 };
        public static readonly HashAlgorithmTag[] RSA_HashAlgorithmTag = new HashAlgorithmTag[] { HashAlgorithmTag.Sha384, HashAlgorithmTag.Sha512 };
    }
}

