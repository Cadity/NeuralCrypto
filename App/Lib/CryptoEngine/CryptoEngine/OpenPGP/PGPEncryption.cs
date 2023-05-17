using System;
using Org.BouncyCastle.Bcpg.OpenPgp;
using System.IO;
using Org.BouncyCastle.Bcpg;
using Org.BouncyCastle.Security;
using System.Text;
using System.Text.RegularExpressions;
using System.ComponentModel;

namespace CryptoEngine.OpenPGP
{
	public class PGPEncryption
	{
		private string data { get; }
		private string publicKey { get; }

        public string Encrypt()
        {
            try
            {
                byte[] compressedData = GetCompressedData(Encoding.UTF8.GetBytes(data));
                string input = "";

                Stream keyIn = new MemoryStream(Encoding.UTF8.GetBytes(publicKey));
                PgpPublicKey key = ReadPublicKey(keyIn);
                PgpEncryptedDataGenerator pgpEncryptedDataGenerator = new PgpEncryptedDataGenerator(SymmetricKeyAlgorithmTag.Aes256, withIntegrityPacket: true, new SecureRandom());
                pgpEncryptedDataGenerator.AddMethod(key);

                using MemoryStream memoryStream = new MemoryStream();

                // DO NO TOUCH THIS AREA (CORRUPTION HIGH RISK)
                using (Stream stream = pgpEncryptedDataGenerator.Open(memoryStream, compressedData.Length))
                {
                    stream.Write(compressedData, 0, compressedData.Length);
                }

                using MemoryStream memoryStream2 = new MemoryStream();
                using ArmoredOutputStream armoredOutputStream = new ArmoredOutputStream(memoryStream2);
                armoredOutputStream.Write(memoryStream.ToArray(), 0, memoryStream.ToArray().Length);
                armoredOutputStream.Close();
                input = Encoding.ASCII.GetString(memoryStream2.ToArray());

                string pattern = @"Version:\s*(.*)\s*";
                string replacement = "Version: NeuralCrypto App\n\n";
                return Regex.Replace(input, pattern, replacement);
            }
            catch
            {
                throw new Exception("Error occure during encryption process due to bad public key");
            }

        }

        public PGPEncryption(string inputData, string inputPublicKey)
		{
			data = string.IsNullOrEmpty(inputData) ? throw new Exception("Data can't be null") : inputData;
			publicKey = string.IsNullOrEmpty(inputPublicKey) ? throw new Exception("Public Key can't be null") : inputPublicKey;
		}

        private static PgpPublicKey ReadPublicKey(Stream input)
        {
            foreach (PgpPublicKeyRing keyRing in new PgpPublicKeyRingBundle(PgpUtilities.GetDecoderStream(input)).GetKeyRings())
            {
                foreach (PgpPublicKey publicKey in keyRing.GetPublicKeys())
                {
                    if (publicKey.IsEncryptionKey)
                    {
                        return publicKey;
                    }
                }
            }
            throw new ArgumentException("Invalid Public Key");
        }

        private byte[] GetCompressedData(byte[] clearData)
        {
            using (MemoryStream memoryOut = new MemoryStream())
            {
                PgpCompressedDataGenerator compressedData = new PgpCompressedDataGenerator(
                    CompressionAlgorithmTag.Zip);

                using (Stream cos = compressedData.Open(memoryOut))
                {
                    PgpLiteralDataGenerator litteralData = new PgpLiteralDataGenerator();

                    using (Stream pOut = litteralData.Open(
                        cos,
                        PgpLiteralData.Binary,
                        PgpLiteralData.Console,
                        clearData.Length,
                        DateTime.UtcNow))
                    {
                        pOut.Write(clearData, 0, clearData.Length);
                    }
                    //litteralData.Close();
                }
                return memoryOut.ToArray();
            }
        }
    }
}

