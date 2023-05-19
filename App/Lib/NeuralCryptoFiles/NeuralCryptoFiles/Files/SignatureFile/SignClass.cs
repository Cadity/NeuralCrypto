using System;
using System.Collections.Generic;
using System.IO;
using CryptoEngine.OpenPGP;
using Intents;
using NeuralCryptoFiles.Files.FileFunction;
using System.Threading.Tasks;
using CryptoEngine.HashFunction;
using System.IO.Compression;

namespace NeuralCryptoFiles.Files.SignatureFile
{
    public class MakeSignFile
    {
        private SignFileParameters parameters { get; }
        private string publicKey { get; set; }
        private string unsignedFile { get; set; }
        public string signedFile { get; set; }

        public MakeSignFile(SignFileParameters param)
        {
            parameters = param;
            CheckFile();
            MakeFile();
            TerminateProcess();
        }

        private void CheckFile()
        {
            if (!Directory.Exists(parameters.copyFilePath))
                Directory.CreateDirectory(parameters.copyFilePath);
            else { Directory.Delete(parameters.copyFilePath, true); Directory.CreateDirectory(parameters.copyFilePath); }

            foreach (var element in parameters.filePath)
            {
                try
                {
                    FileInfo info = new FileInfo(element);
                    File.Copy(element, parameters.copyFilePath + info.Name);
                }
                catch { }
            }
        }

        private void MakeFile()
        {
            var makeNCSectionTask = Task.Run(() =>
            {
                return Task.FromResult(NeuralCrypto_Section.Make());
            });
            var makeFileIdentitySectionTask = Task.Run(() =>
            {
                return Task.FromResult(FileIdentity_Section.Make(parameters, "Signature File"));
            });
            var makeCommentSectionTask = Task.Run(() =>
            {
                return Task.FromResult(Comment_Section.Make(parameters));
            });
            var getPublicKeyTask = Task.Run(() =>
            {
                try
                {
                    ReadPGPKey read = new ReadPGPKey(parameters.privateKey);
                    read.isPublic();
                    read.CheckPassword(parameters.passwordKey);
                    return Task.FromResult(read.GetPrivateKeyPacket().readablePublicKey);
                }
                catch { throw new Exception("Can't read private key"); }
            });

            Task.WaitAll(makeNCSectionTask, makeFileIdentitySectionTask, makeCommentSectionTask, getPublicKeyTask);
            unsignedFile += makeNCSectionTask.Result + "\n" + makeFileIdentitySectionTask.Result + "\n" + makeCommentSectionTask.Result;
            publicKey = getPublicKeyTask.Result;

            Parallel.ForEach(parameters.filePath, element =>
            {
                FileInfo file = new FileInfo(element);
                var bloc = "File Section\n{\n\t" +
                "Name : " + file.Name + "\n\t" +
                "Size : " + file.Length + "\n\t" +
                "Hash : " + SHAFunction.GetHash(File.ReadAllText(element), "SHA512", "base64") + "\n}";

                unsignedFile += "\n" + bloc;
            });
        }

        private void TerminateProcess()
        {
            unsignedFile = Hash_Section.Make(unsignedFile);
            PGPMakeSign sign = new PGPMakeSign(unsignedFile, parameters.privateKey, parameters.passwordKey, "SHA512");
            signedFile = sign.SignContent();
            var filePath = parameters.copyFilePath + "Files/";
            Directory.CreateDirectory(filePath);
            File.WriteAllText(filePath + "Signature File.nc", signedFile);
            File.WriteAllText(filePath + "Signatory Public Key.txt", publicKey);

            var zipPath = parameters.outputPath + parameters.fileName + ".zip";
            if (File.Exists(zipPath)) File.Delete(zipPath);

            ZipFile.CreateFromDirectory(parameters.copyFilePath, zipPath);
        }
    }

    public class SignFileParameters
    {
        public List<string> filePath { get; set; }
        public DateTime expirationDate { get; set; }
        public string author { get; set; }
        public string privateKey { get; set; }
        public string passwordKey { get; set; }
        public string userComment { get; set; }
        public string fileName { get; set; }
        public string copyFilePath { get; set; }
        public string outputPath { get; set; }
    }
}

