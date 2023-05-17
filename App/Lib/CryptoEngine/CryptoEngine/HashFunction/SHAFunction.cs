using System;
using System.Security.Cryptography;
using System.Text;
using System.Collections.Generic;

namespace CryptoEngine.HashFunction
{
    public static class SHAFunction
    {
        public static string GetHash(string chain, string function, string encoding)
        {
            if (string.IsNullOrEmpty(chain) || string.IsNullOrEmpty(function) || string.IsNullOrEmpty(encoding))
                throw new NullOrEmptyArgument("One or more arguments are empty or null ! Check args passed to the constructor");

            byte[] array = function switch
            {
                "SHA256" => SHA256.Create().ComputeHash(Encoding.UTF8.GetBytes(chain)),
                "SHA384" => SHA384.Create().ComputeHash(Encoding.UTF8.GetBytes(chain)),
                "SHA512" => SHA512.Create().ComputeHash(Encoding.UTF8.GetBytes(chain)),
                _ => throw new InvalidArgumentException("Invalid hash function"),
            };

            switch (encoding)
            {
                case "base64":
                    return Convert.ToBase64String(array);
                case "hexadecimal":
                    return BitConverter.ToString(array).Replace("-", "");
                default:
                    throw new InvalidArgumentException("Invalid encoding arg");
            }
        }
    }

    public class NullOrEmptyArgument : Exception
    {
        public NullOrEmptyArgument()
        {
        }

        public NullOrEmptyArgument(string message) : base(message)
        {
        }
    }

    public class InvalidArgumentException : Exception
    {
        public InvalidArgumentException()
        {
        }

        public InvalidArgumentException(string message) : base(message)
        {
        }
    }
}

