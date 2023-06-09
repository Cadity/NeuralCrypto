﻿using System;
using NeuralCryptoFiles.Files.SignatureFile;
using CryptoEngine.HashFunction;
using System.Text.RegularExpressions;
using System.Globalization;

namespace NeuralCryptoFiles.Files.FileFunction
{
    public static class Hash_Section
    {
        public static string Make(string file)
        {
            var hash = SHAFunction.GetHash(file, "SHA512", "base64");
            string beginHeader = "----- BEGIN NEURALCRYPTO FILE -----\n";
            string endHeader = "\n----- END NEURALCRYPTO FILE -----";

            return beginHeader + "Hash Section\n{\n\t" +
                "Hash Function : SHA512\n\t" +
                "Encoding : 0x64\n\t" +
                "Hash : " + hash + "\n}\n" + file + endHeader;
        }

        public static (string, string, bool, string) Read(string file)
        {
            // Order : Marked Hash, Real Hash, isValid (bool), Function

            Match match = Regex.Match(file, @"Hash Section\n{\n\tHash Function : (?<HashFunction>\w+)\n\tEncoding : (?<Encoding>\w+)\n\tHash : (?<Hash>[\w\/\+=]+)", RegexOptions.Singleline);

            string hash = "", function = "", encoding = ""; bool isValid = true;

            if (match.Success)
            {
                function = match.Groups["HashFunction"].Value;
                encoding = match.Groups["Encoding"].Value;
                hash = match.Groups["Hash"].Value;
            }
            else
                throw new Exception("Hash Section not readable");

            file = Regex.Replace(file, @"----- BEGIN NEURALCRYPTO FILE -----\n", string.Empty);
            file = Regex.Replace(file, @"\n----- END NEURALCRYPTO FILE -----\n", string.Empty);
            file = Regex.Replace(file, @"Hash Section[^}]+}\n", string.Empty);

            string GetEncoding(string encoding)
            {
                return encoding switch
                {
                    "0x64" => "base64",
                    "0x16" => "hexadecimal",
                    _ => throw new Exception("Invalid encoding"),
                };
            }

            var realHash = SHAFunction.GetHash(file, function, GetEncoding(encoding));

            if (hash != realHash)
                isValid = false;

            return (hash, realHash, isValid, function);
        }
    }

	public static class NeuralCrypto_Section
	{
		public static string Make()
		{
            return "NeuralCrypto Section\n{\n\tVersion : Alpha 1.0\n}";
        }

        public static string Read(string file)
        {
            Match match = Regex.Match(file, @"NeuralCrypto Section\n{\n\tVersion : (?<Version>[^\n]+)");
            if (match.Success)
                return match.Groups["Version"].Value;
            else
                return "Undetected Version ; Can't verify version of NeuralCrypto !";
        }
    }

    public static class FileIdentity_Section
    {
        public static string Make(SignFileParameters parameters, string type)
        {
            return "File Identity Section\n{\n\t" +
                "Type : " + type + "\n\t" +
                "Creation Date : " + DateTime.Now.ToString("dd/MM/yyyy HH:mm") + "\n\t" +
                "Expiration Date : " + parameters.expirationDate.ToString("dd/MM/yyyy HH:mm") + "\n\t" +
                "Author : " + parameters.author + "\n}";
        }

        public static (string, DateTime, DateTime, string) Read(string file)
        {
            Match match = Regex.Match(file, @"File Identity Section\n{\n\tType : (?<Type>[^\n]+)\n\tCreation Date : (?<CreationDate>[^\n]+)\n\tExpiration Date : (?<ExpirationDate>[^\n]+)\n\tAuthor : (?<Author>[^\n]+)");

            if(match.Success)
            {
                // Order : Type ; CreationDate ;  ExpirationDate ; Author

                return (match.Groups["Type"].Value, DateTime.ParseExact(match.Groups["CreationDate"].Value, "dd/MM/yyyy HH:mm", CultureInfo.CreateSpecificCulture("fr-FR")), DateTime.ParseExact(match.Groups["ExpirationDate"].Value, "dd/MM/yyyy HH:mm", CultureInfo.CreateSpecificCulture("fr-FR")), match.Groups["Author"].Value);
            }

            throw new Exception("Critical : File Identity Section unreadable");
        }
    }

    public static class Comment_Section
    {
        public static string Make(SignFileParameters parameters)
        {
            return "Comment Section\n{\n\tAuto-Generated Section : This file has been generated by NeuralCrypto using SHA-512\n\t" +
                "Author-Comment : " + parameters.userComment + ";\n}";
        }

        public static (string, string) Read(string file)
        {
            Match match = Regex.Match(file, @"Comment Section\n{\n\tAuto-Generated Section : (?<NCComment>[^\n]+)\n\tAuthor-Comment : (?<AuthorComment>[^;]+)");
            if (match.Success)
                return (match.Groups["NCComment"].Value, match.Groups["AuthorComment"].Value);
            else
                return ("None", "None");
        }
    }
}

