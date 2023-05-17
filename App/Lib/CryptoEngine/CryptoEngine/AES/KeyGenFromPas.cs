using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using CryptoEngine.HashFunction;

namespace CryptoEngine.AES
{
    public static class KeyGenFromPass
    {
        public static List<byte[]> GetKey(string password)
        {
            var keys = GetKeyFromPass(password);
            if (KeyTest(keys) == true)
                return keys;
            else
                return null;
        }

        internal static List<byte[]> GetKeyFromPass(string password)
        {
            var hash = SHAFunction.GetHash(password, "SHA512", "base64");
            var key = Convert.FromBase64String(hash.Substring(0, 43) + "=");
            var iv = Convert.FromBase64String(hash.Substring(53, 22) + "==");

            return new List<byte[]> { key, iv };
        }

        public static bool KeyTest(List<byte[]> key)
        {
            // Generate random Number
            int i = 0;
            string chain = "";
            Random random = new Random();

            for (i = 0; i <= 5; i++)
            {
                chain = chain + random.Next().ToString();
            }

            string randomChain = Convert.ToBase64String(Encoding.UTF8.GetBytes(chain));
            byte[] cypheredRandomChain = AES.Encrypt(randomChain, key[0], key[1], true);
            string uncypheredRandomChain = AES.Decrypt(cypheredRandomChain, key[0], key[1]);

            if (uncypheredRandomChain == randomChain)
                return true;
            else
                return false;

        }
    }
}

