using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using LocalAuthentication;
using Org.BouncyCastle.Bcpg;
using Org.BouncyCastle.Bcpg.OpenPgp;

namespace CryptoEngine.OpenPGP
{
    public class ReadPGPKey
    {
        private string key { get; set; }
        private bool isPrimalAnalysisDone { get; set; }
        private char[] password { get; set; }

        public ReadPGPKey(string inputKey)
        {
            key = string.IsNullOrEmpty(inputKey) ? throw new Exception("Null or Empty Key") : inputKey;
            key = inputKey;
            isPrimalAnalysisDone = false;
        }

        public bool isPublic()
        {
            isPrimalAnalysisDone = true;
            string keyType = "";

            Match match = Regex.Match(key, @"-----BEGIN PGP PUBLIC KEY BLOCK-----\n.*-----END PGP PUBLIC KEY BLOCK-----", RegexOptions.Singleline);
            if (match.Success)
                keyType = "public";

            match = Regex.Match(key, @"-----BEGIN PGP PRIVATE KEY BLOCK-----\n.*-----END PGP PRIVATE KEY BLOCK-----", RegexOptions.Singleline);
            if (match.Success)
                keyType += "private";


            return keyType switch
            {
                "public" => true,
                "private" => false,
                _ => throw new Exception("Invalid key ! Both type are detected")

            };
        }

        public PgpPublicKeyPacket GetPublicKeyPacket()
        {
            if (isPrimalAnalysisDone == false)
                throw new Exception("Primal analysis hasn't been made");

            var inputPublicKey = ReadUtilities.ReadPublicKey(key);
            var enumUserIds = inputPublicKey.GetUserIds();
            string identity = "";
            foreach (var element in enumUserIds)
            {
                identity = element.ToString();
            }

            PgpPublicKeyPacket packet = new PgpPublicKeyPacket()
            {
                keySize = inputPublicKey.BitStrength,
                algorithm = inputPublicKey.Algorithm.ToString(),
                creationTime = inputPublicKey.CreationTime,
                masterKeyFingerPrint = ReadUtilities.FormateFingerPrint(inputPublicKey.GetFingerprint()),
                validitySecond = inputPublicKey.GetValidSeconds(),
                keyId = inputPublicKey.KeyId,
                publicKey = inputPublicKey,
                readableKey = ReadUtilities.RecreatePublicKey(inputPublicKey),
            };
            packet.expirationDate = DateTime.UtcNow.AddSeconds((double)packet.validitySecond);

            Regex regex = new Regex(@"^([\w\s]+)(?: \(([\w\s]+)\))?(?: <([\w.@]+)>)?$");

            if (regex.IsMatch(identity))
            {
                Match match = regex.Match(identity);
                packet.username = match.Groups[1].Value.Trim();
                packet.keycomment = match.Groups[2].Success ? match.Groups[2].Value.Trim() : "none";
                packet.usermail = match.Groups[3].Success ? match.Groups[3].Value.Trim() : "none";
            }
            return packet;
        }

        public PgpPrivateKeyPacket GetPrivateKeyPacket()
        {
            if (isPrimalAnalysisDone == false || password == null)
                throw new Exception("Primal analysis or Password Chek or both hasn't been made");

            var inputSecretKey = ReadUtilities.ReadSecretKey(key);
            var inputPrivateKey = inputSecretKey.ExtractPrivateKey(password);

            PgpPrivateKeyPacket packet = new PgpPrivateKeyPacket()
            {
                readablePublicKey = ReadUtilities.RecreatePublicKey(inputSecretKey.PublicKey),
                publicKey = inputSecretKey.PublicKey,
                privateKey = inputPrivateKey,
                secretKey = inputSecretKey,
                keyEncryptionAlgorithm = inputSecretKey.KeyEncryptionAlgorithm,
            };

            key = packet.readablePublicKey;
            packet.publicKeyPaquet = GetPublicKeyPacket();

            return packet;
        }

        public void CheckPassword(string inputPassword)
        {
            try
            {
                var secretKey = ReadUtilities.ReadSecretKey(key);
                var privateKey = secretKey.ExtractPrivateKey(inputPassword.ToCharArray());
                password = inputPassword.ToCharArray();
            }
            catch
            { throw new InvalidPrivateKeyPasswordException(); }
        }
    }

    public class PgpPublicKeyPacket
    {
        public int keySize { get; set; }
        public string algorithm { get; set; }
        public DateTime creationTime { get; set; }
        public string masterKeyFingerPrint { get; set; }
        public long validitySecond { get; set; }
        public DateTime expirationDate { get; set; }
        public long keyId { get; set; }
        public string username { get; set; }
        public string usermail { get; set; }
        public string keycomment { get; set; }
        public PgpPublicKey publicKey { get; set; }
        public string readableKey { get; set; }
    }

    public class PgpPrivateKeyPacket
    {
        public string readablePublicKey { get; set; }
        public PgpPublicKey publicKey { get; set; }
        public PgpPrivateKey privateKey { get; set; }
        public PgpSecretKey secretKey { get; set; }
        public PgpPublicKeyPacket publicKeyPaquet { get; set; }
        public SymmetricKeyAlgorithmTag keyEncryptionAlgorithm { get; set; }
    }

    internal static class ReadUtilities
    {
        public static PgpPublicKey ReadPublicKey(string inputKey)
        {
            using (Stream publicKeyStream = new MemoryStream(Encoding.ASCII.GetBytes(inputKey)))
            {
                PgpPublicKeyRingBundle pgpPub = new PgpPublicKeyRingBundle(
                PgpUtilities.GetDecoderStream(publicKeyStream));
                foreach (PgpPublicKeyRing keyRing in pgpPub.GetKeyRings())
                {
                    foreach (PgpPublicKey key in keyRing.GetPublicKeys())
                    {
                        return key;
                    }
                }
                throw new Exception("No key founded");
            }
        }

        public static string FormateFingerPrint(byte[] fingerPrint)
        {
            string hexString = BitConverter.ToString(fingerPrint).Replace("-", "");
            string formattedHexString = String.Join(" ", Enumerable.Range(0, hexString.Length / 4)
                .Select(i => hexString.Substring(i * 4, 4)));

            return formattedHexString;
        }

        public static string RecreatePublicKey(PgpPublicKey key)
        {
            string publicKeyArmored = "";

            using (MemoryStream memStream = new MemoryStream())
            {
                using (ArmoredOutputStream armoredStream = new ArmoredOutputStream(memStream))
                {
                    key.Encode(armoredStream);
                    armoredStream.Close();
                    publicKeyArmored = Encoding.ASCII.GetString(memStream.ToArray());
                }
            }

            return Regex.Replace(publicKeyArmored, @"Version:\s*(.*)\s*", "Version: NeuralCrypto App\n\n");
        }

        public static PgpSecretKey ReadSecretKey(string privateKey)
        {
            using (Stream secretKeyStream = new MemoryStream(Encoding.ASCII.GetBytes(privateKey)))
            {
                PgpSecretKeyRingBundle pgpSec = new PgpSecretKeyRingBundle(
                PgpUtilities.GetDecoderStream(secretKeyStream));

                foreach (PgpSecretKeyRing keyRing in pgpSec.GetKeyRings())
                {
                    foreach (PgpSecretKey key in keyRing.GetSecretKeys())
                    {
                        return key;
                    }
                }
                throw new ArgumentException("Other object than private key detected !");

            }
        }
    }

    internal class InvalidPrivateKeyPasswordException : Exception
    {
        public InvalidPrivateKeyPasswordException()
        {
        }

        public InvalidPrivateKeyPasswordException(string message) : base(message)
        {
        }
    }
}

