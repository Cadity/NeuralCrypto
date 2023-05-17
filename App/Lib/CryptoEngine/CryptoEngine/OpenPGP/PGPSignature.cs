using System;
using Org.BouncyCastle.Bcpg;
using Org.BouncyCastle.Bcpg.OpenPgp;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using CryptoEngine.OpenPGP.SignTools;
using static System.Net.Mime.MediaTypeNames;
using CoreGraphics;

namespace CryptoEngine.OpenPGP
{
    public class PGPMakeSign
    {
        public HashAlgorithmTag digest { get; }
        private PgpPrivateKey privateKey { get; }
        private PgpSecretKey secretKey { get; set; }
        private char[] password { get; }
        private Stream inputStream { get; }

        public PGPMakeSign(string data, string inputPrivateKey, string inputPassword, string hashFunction)
        {
            inputStream = string.IsNullOrEmpty(data) ? throw new ArgumentNullException("null/empty data") : new MemoryStream(Encoding.UTF8.GetBytes(data + "\n"));
            password = string.IsNullOrEmpty(inputPassword) ? throw new Exception("null/empty password") : inputPassword.ToCharArray();
            privateKey = string.IsNullOrEmpty(inputPrivateKey) ? throw new ArgumentNullException("null/empty privateKey") : GetPrivateKey(inputPrivateKey);
            digest = GetHashFunction(hashFunction);
        }

        private PgpPrivateKey GetPrivateKey(string key)
        {
            MemoryStream keyIn = new MemoryStream(Encoding.ASCII.GetBytes(key));
            secretKey = SignUtilities.ReadSecretKey(keyIn);
            try
            {
                return secretKey.ExtractPrivateKey(password);
            }
            catch (Exception)
            {
                throw new Exception("Incorrect password for privateKey");
            }
        }

        private HashAlgorithmTag GetHashFunction(string hashFunction)
        {
            return hashFunction switch
            {
                "SHA256" => HashAlgorithmTag.Sha256,
                "SHA384" => HashAlgorithmTag.Sha384,
                "SHA512" => HashAlgorithmTag.Sha512,
                _ => throw new Exception("Invalid hash function"),
            };
        }

        public string SignContent()
        {
            string signingText = "";

            PgpSignatureGenerator sGen = new PgpSignatureGenerator(secretKey.PublicKey.Algorithm, digest);
            PgpSignatureSubpacketGenerator spGen = new PgpSignatureSubpacketGenerator();
            sGen.InitSign(PgpSignature.CanonicalTextDocument, privateKey);
            var enumerator = secretKey.PublicKey.GetUserIds().GetEnumerator();
            if (enumerator.MoveNext())
            {
                spGen.SetSignerUserId(false, (string)enumerator.Current);
                sGen.SetHashedSubpackets(spGen.Generate());
            }

            MemoryStream outputStream = new MemoryStream();
            ArmoredOutputStream armoredOutputStream = new ArmoredOutputStream(outputStream);
            armoredOutputStream.BeginClearText(digest);
            MemoryStream lineOut = new MemoryStream();
            int lookAhead = SignUtilities.ReadInputLine(lineOut, inputStream);
            SignUtilities.ProcessLine(armoredOutputStream, sGen, lineOut.ToArray());
            if (lookAhead != -1)
            {
                do
                {
                    lookAhead = SignUtilities.ReadInputLine(lineOut, lookAhead, inputStream);

                    sGen.Update((byte)'\r');
                    sGen.Update((byte)'\n');

                    SignUtilities.ProcessLine(armoredOutputStream, sGen, lineOut.ToArray());
                }
                while (lookAhead != -1);
            }

            armoredOutputStream.EndClearText();
            BcpgOutputStream bOut = new BcpgOutputStream(armoredOutputStream);
            sGen.Generate().Encode(bOut);
            armoredOutputStream.Close();
            outputStream.Close();

            signingText = Encoding.UTF8.GetString(outputStream.ToArray());

            return Regex.Replace(signingText, @"Version:\s*(.*)\s*", "Version: NeuralCrypto App\n\n");
        }
    }

    public class PGPCheckSign
    {
        private Stream keyStream { get; }
        private Stream inputStream { get; }
        public string hashFunction { get; }
        public (bool, string) signatureVersion { get; }

        public PGPCheckSign(string inputSign, string publicKey)
        {
            inputStream = string.IsNullOrEmpty(inputSign) ? throw new Exception("null/empty sign") : new MemoryStream(Encoding.UTF8.GetBytes(inputSign));
            hashFunction = GetHashFunction(inputSign);
            signatureVersion = AnalyseSignature(inputSign);
            keyStream = string.IsNullOrEmpty(publicKey) ? throw new Exception("null/empty key") : PgpUtilities.GetDecoderStream(new MemoryStream(Encoding.ASCII.GetBytes(publicKey)));
        }

        public string CheckSign()
        {
            ArmoredInputStream armoredInput = new ArmoredInputStream(inputStream);
            MemoryStream lineOut = new MemoryStream();
            int lookAhead = SignUtilities.ReadInputLine(lineOut, armoredInput);
            byte[] lineSep = SignUtilities.LineSeparator;

            MemoryStream outStream = new MemoryStream();

            if (lookAhead != -1 && armoredInput.IsClearText())
            {
                byte[] line = lineOut.ToArray();
                outStream.Write(line, 0, SignUtilities.GetLengthWithoutSeparatorOrTrailingWhitespace(line));
                outStream.Write(lineSep, 0, lineSep.Length);

                while (lookAhead != -1 && armoredInput.IsClearText())
                {
                    lookAhead = SignUtilities.ReadInputLine(lineOut, lookAhead, armoredInput);

                    line = lineOut.ToArray();
                    outStream.Write(line, 0, SignUtilities.GetLengthWithoutSeparatorOrTrailingWhitespace(line));
                    outStream.Write(lineSep, 0, lineSep.Length);
                }
            }
            else
            {
                if (lookAhead != -1)
                {
                    byte[] line = lineOut.ToArray();
                    outStream.Write(line, 0, SignUtilities.GetLengthWithoutSeparatorOrTrailingWhitespace(line));
                    outStream.Write(lineSep, 0, lineSep.Length);
                }
            }

            outStream.Flush();

            PgpPublicKeyRingBundle pgpRings = new PgpPublicKeyRingBundle(keyStream);
            PgpObjectFactory pgpFact = new PgpObjectFactory(armoredInput);
            PgpSignatureList p3 = (PgpSignatureList)pgpFact.NextPgpObject();
            PgpSignature sig = p3[0];

            var key = pgpRings.GetPublicKey(sig.KeyId);
            if (key == null)
            {
                throw new Exception("Can't verify the message signature.");
            }
            sig.InitVerify(key);

            outStream.Seek(0, SeekOrigin.Begin);
            StreamReader reader = new StreamReader(outStream);
            string messageContent = reader.ReadToEnd();

            outStream.Seek(0, SeekOrigin.Begin);

            Stream sigIn = outStream;

            lookAhead = SignUtilities.ReadInputLine(lineOut, sigIn);

            SignUtilities.ProcessLine(sig, lineOut.ToArray());

            if (lookAhead != -1)
            {
                do
                {
                    lookAhead = SignUtilities.ReadInputLine(lineOut, lookAhead, sigIn);

                    sig.Update((byte)'\r');
                    sig.Update((byte)'\n');

                    SignUtilities.ProcessLine(sig, lineOut.ToArray());
                }
                while (lookAhead != -1);
            }

            sigIn.Close();

            if (sig.Verify())
            {
                return messageContent;
            }
            else
            {
                throw new Exception("Can't verify the message signature.");
            }
        }

        private static string GetHashFunction(string signature)
        {
            List<string> hashFunctionList = new List<string> { "SHA256", "SHA384", "SHA512" };
            string hashFunction = "";
            Match match = Regex.Match(signature, @"Hash: (?<HashFunction>\w+)\n");
            if (match.Success)
            {
                hashFunction = match.Groups["HashFunction"].Value;
                if (!hashFunctionList.Contains(hashFunction))
                    throw new InvalidSignHashFunction(hashFunction + " isn't a valid hash function");
                else
                    return hashFunction;
            }
            else
                throw new UndetectableSignHashFunction("Can't reach hash function");
        }

        private static (bool, string) AnalyseSignature(string signature)
        {
            Match match = Regex.Match(signature, @"Version: (?<Commentary>.*)");
            if (match.Success)
            {
                if ((match.Groups["Commentary"].Value == "NeuralCrypto App"))
                    return (true, "Signature is from NeuralCrypto");
                else
                    return (true, "Signature isn't from NeuralCrypto");
            }
            else
                return (false, "Signature can't be verified");
        }
    }
}

namespace CryptoEngine.OpenPGP
{
    internal static class SignUtilities
    {
        public static PgpSecretKey ReadSecretKey(string fileName)
        {
            using (Stream keyIn = File.OpenRead(fileName))
            {
                return ReadSecretKey(keyIn);
            }
        }

        public static PgpSecretKey ReadSecretKey(Stream input)
        {
            PgpSecretKeyRingBundle pgpSec = new PgpSecretKeyRingBundle(
                PgpUtilities.GetDecoderStream(input));

            foreach (PgpSecretKeyRing keyRing in pgpSec.GetKeyRings())
            {
                foreach (PgpSecretKey key in keyRing.GetSecretKeys())
                {
                    if (key.IsSigningKey)
                    {
                        return key;
                    }
                }
            }
            throw new ArgumentException("Can't find signing key in key ring.");
        }

        public static int ReadInputLine(MemoryStream bOut, Stream fIn)
        {
            bOut.SetLength(0);

            int lookAhead = -1;
            int ch;

            while ((ch = fIn.ReadByte()) >= 0)
            {
                bOut.WriteByte((byte)ch);
                if (ch == '\r' || ch == '\n')
                {
                    lookAhead = ReadPassedEol(bOut, ch, fIn);
                    break;
                }
            }

            return lookAhead;
        }

        public static int ReadInputLine(MemoryStream bOut, int lookAhead, Stream fIn)
        {
            bOut.SetLength(0);

            int ch = lookAhead;

            do
            {
                bOut.WriteByte((byte)ch);
                if (ch == '\r' || ch == '\n')
                {
                    lookAhead = ReadPassedEol(bOut, ch, fIn);
                    break;
                }
            }
            while ((ch = fIn.ReadByte()) >= 0);

            if (ch < 0)
            {
                lookAhead = -1;
            }

            return lookAhead;
        }

        public static int ReadPassedEol(MemoryStream bOut, int lastCh, Stream fIn)
        {
            int lookAhead = fIn.ReadByte();

            if (lastCh == '\r' && lookAhead == '\n')
            {
                bOut.WriteByte((byte)lookAhead);
                lookAhead = fIn.ReadByte();
            }

            return lookAhead;
        }

        public static void ProcessLine(PgpSignature sig, byte[] line)
        {
            int length = GetLengthWithoutWhiteSpace(line);
            if (length > 0)
            {
                sig.Update(line, 0, length);
            }
        }

        public static void ProcessLine(Stream aOut, PgpSignatureGenerator sGen, byte[] line)
        {
            int length = GetLengthWithoutWhiteSpace(line);
            if (length > 0)
            {
                sGen.Update(line, 0, length);
            }

            aOut.Write(line, 0, line.Length);
        }

        public static int GetLengthWithoutSeparatorOrTrailingWhitespace(byte[] line)
        {
            int end = line.Length - 1;

            while (end >= 0 && IsWhiteSpace(line[end]))
            {
                end--;
            }

            return end + 1;
        }

        public static bool IsLineEnding(byte b)
        {
            return b == '\r' || b == '\n';
        }

        public static int GetLengthWithoutWhiteSpace(byte[] line)
        {
            int end = line.Length - 1;

            while (end >= 0 && IsWhiteSpace(line[end]))
            {
                end--;
            }

            return end + 1;
        }

        public static bool IsWhiteSpace(byte b)
        {
            return IsLineEnding(b) || b == '\t' || b == ' ';
        }

        public static byte[] LineSeparator
        {
            get { return Encoding.ASCII.GetBytes(Environment.NewLine); }
        }
    }
}

namespace CryptoEngine.OpenPGP.SignTools
{
    public class WrongSignatureSyntaxis : Exception
    {
        public WrongSignatureSyntaxis()
        {
        }

        public WrongSignatureSyntaxis(string message) : base(message)
        {
        }
    }

    public class UndetectableSignHashFunction : Exception
    {
        public UndetectableSignHashFunction()
        {
        }

        public UndetectableSignHashFunction(string message) : base(message)
        {
        }
    }

    public class InvalidSignHashFunction : Exception
    {
        public InvalidSignHashFunction()
        {
        }

        public InvalidSignHashFunction(string message) : base(message)
        {
        }
    }
}

