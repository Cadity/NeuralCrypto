using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using CryptoEngine.HashFunction;

namespace CryptoEngine.AES
{
    public static class AES
    {
        public static List<byte[]> DefineKeys(int size)
        {
            if (!(size == 128 || size == 192 || size == 256))
                throw new Exception("Invalid Size ! Check arg passed to the function");

            Aes aes = Aes.Create();
            aes.KeySize = size;

            aes.GenerateKey();
            aes.GenerateIV();

            return new List<byte[]> { aes.Key, aes.IV };
        }

        public static byte[] Encrypt(string data, byte[] key, byte[] iv, bool secureTransform)
        {
            if (string.IsNullOrEmpty(data) || key == null || iv == null)
                throw new Exception("Invalid args ! Check args passed to the function");

            string inputHash = "";

            if (secureTransform == true)
                inputHash = SHAFunction.GetHash(data, "SHA512", "base64");

            var input = Encoding.UTF8.GetBytes(data);
            byte[] cypheredData;

            try
            {
                Aes aes = Aes.Create();
                aes.Mode = CipherMode.CBC;
                aes.Key = key;
                aes.IV = iv;
                ICryptoTransform cryptoTransform = aes.CreateEncryptor(aes.Key, aes.IV);
                MemoryStream ms = new MemoryStream();
                CryptoStream cs = new CryptoStream(ms, cryptoTransform, CryptoStreamMode.Write);
                cs.Write(input, 0, input.Length);
                cs.FlushFinalBlock();
                cypheredData = ms.ToArray();

                if (secureTransform == true)
                {
                    var decypheredHash = SHAFunction.GetHash(Decrypt(cypheredData, key, iv), "SHA512", "base64");
                    if (!(inputHash == decypheredHash))
                        throw new Exception("Error occure during encryption process");
                    else
                        return cypheredData;
                }
                else
                    return cypheredData;
            }
            catch { throw new Exception("Key or IV or both are invalid ! Check args"); }
        }

        public static string Decrypt(byte[] data, byte[] key, byte[] iv)
        {
            if (data == null || key == null || iv == null)
                throw new Exception("Invalid args ! Check args passed to the function");

            try
            {
                string uncypheredData = "";
                Aes aes = Aes.Create();
                aes.Key = key;
                aes.IV = iv;
                aes.Mode = CipherMode.CBC;
                ICryptoTransform cryptoTransform = aes.CreateDecryptor(aes.Key, aes.IV);
                MemoryStream ms = new MemoryStream();
                CryptoStream cs = new CryptoStream(ms, cryptoTransform, CryptoStreamMode.Write);
                cs.Write(data, 0, data.Length);
                cs.FlushFinalBlock();
                uncypheredData = Encoding.UTF8.GetString(ms.ToArray());

                return uncypheredData;
            }
            catch { throw new Exception("Decryption Failled => Invalid Key, IV or Both"); }
        }

        public static bool TestKey(string key, string IV)
        {
            List<byte[]> keys = new List<byte[]>();
            try { keys.Add(Convert.FromBase64String(key)); keys.Add(Convert.FromBase64String(IV)); }
            catch { return false; }

            Random random = new Random();
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            string randomString = new string(Enumerable.Repeat(chars, 64).Select(s => s[random.Next(s.Length)]).ToArray());
            var cypheredRandString = Encrypt(randomString.ToString(), keys[0], keys[1], false);
            var decypheredRandString = Decrypt(cypheredRandString, keys[0], keys[1]);

            if (randomString == decypheredRandString)
                return true;
            else
                return false;
        }
    }
}

