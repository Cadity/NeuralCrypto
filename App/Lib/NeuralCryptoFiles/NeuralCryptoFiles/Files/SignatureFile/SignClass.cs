using System;
using System.Collections.Generic;
using System.IO;
using CryptoEngine.OpenPGP;
using Intents;
using NeuralCryptoFiles.Files.FileFunction;
using System.Threading.Tasks;
using CryptoEngine.HashFunction;
using System.IO.Compression;
using System.Text.RegularExpressions;
using System.Linq;

// Create SignFile
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

// Read Sign File
namespace NeuralCryptoFiles.Files.SignatureFile
{
    public enum FileStatut
    {
        Invalid, Partial, Missing, Valid
    }

    public class FoundedFile
    {
        public string name { get; set; }
        public long size { get; set; }
        public FileStatut statut { get; set; }
    }

    public class SignFilePacket
    {
        public string author { get; set; }
        public string ncVersion { get; set; }
        public string ncComment { get; set; }
        public string userComment { get; set; }
        public string signatureHash { get; set; }
        public string signatureFunction { get; set; }
        public int invalidFiles { get; set; }
        public List<FoundedFile> files { get; set; }
        public DateTime creationDate { get; set; }
        public DateTime expirationDate { get; set; }
        public PgpPublicKeyPacket signatoryKeyPacket { get; set; }
    }

    public class ReadSignFile
    {
        public string signature { get; set; }
        private string publicKey { get; set; }
        private int invalidFiles { get; set; }
        private DirectoryInfo dirInfo { get; }
        private DirectoryInfo filesDirInfo { get; set; }
        public SignFilePacket packet { get; set; }
        private List<FoundedFile> files { get; set; }

        public ReadSignFile(string archivePath, string decompressionPath)
        {
            files = new List<FoundedFile>();
            packet = new SignFilePacket();
            dirInfo = CheckArchive(archivePath, decompressionPath);
            GetSignature();
            GetElement();
            packet.files = files;
            packet.invalidFiles = invalidFiles;
        }

        private DirectoryInfo CheckArchive(string path, string decompressionPath)
        {
            if (!File.Exists(path)) throw new Exception("Archive not found");
            if (!Directory.Exists(decompressionPath))
                Directory.CreateDirectory(decompressionPath);
            else
            {
                Directory.Delete(decompressionPath, true);
                Directory.CreateDirectory(decompressionPath);
            }

            ZipFile.ExtractToDirectory(path, decompressionPath);

            DirectoryInfo fileDir = new DirectoryInfo(decompressionPath + "/Files/");
            filesDirInfo = fileDir;

            DirectoryInfo dir = new DirectoryInfo(decompressionPath);
            return dir;
        }

        private void GetSignature()
        {
            try
            {
                var signed = File.ReadAllText(dirInfo.FullName + "Files/Signature File.nc");
                publicKey = File.ReadAllText(dirInfo.FullName + "Files/Signatory Public Key.txt");

                PGPCheckSign check = new PGPCheckSign(signed, publicKey);
                signature = check.CheckSign();
            }
            catch { throw new Exception("Critical can't locate or verify signature"); }
        }

        private void GetElement()
        {
            // Get asynchronly all element
            var getHashSectionTask = Task.Run(() => {
                var result = Hash_Section.Read(signature);
                if (!result.Item3)
                    throw new Exception("Invalid hash in signature");

                return Task.FromResult(result);
            });
            var getNeuralCryptoSectionTask = Task.Run(() => {
                return Task.FromResult(NeuralCrypto_Section.Read(signature));

            });
            var getFileIdentitySectionTask = Task.Run(() => {
                var result = FileIdentity_Section.Read(signature);
                if (result.Item1 != "Signature File") throw new Exception("Bad File Type"); // Check type
                if (result.Item2 > result.Item3) throw new Exception("File expired"); // Check expiration date
                return Task.FromResult(result);
            });
            var getPublicKeyPacketTask = Task.Run(() => {
                ReadPGPKey read = new ReadPGPKey(publicKey);
                read.isPublic();
                return Task.FromResult(read.GetPublicKeyPacket());
            });
            var getCommentSectionTask = Task.Run(() => {
                return Task.FromResult(Comment_Section.Read(signature));
            });

            Task.WaitAll(getHashSectionTask, getNeuralCryptoSectionTask, getFileIdentitySectionTask, getPublicKeyPacketTask, getCommentSectionTask);

            var version = getNeuralCryptoSectionTask.Result;
            var fileId = getFileIdentitySectionTask.Result;
            var hashResult = getHashSectionTask.Result;
            var commentResult = getCommentSectionTask.Result;

            packet.signatureFunction = hashResult.Item4;
            packet.signatureHash = hashResult.Item2;
            packet.ncVersion = version;
            packet.author = fileId.Item4;
            packet.creationDate = fileId.Item2;
            packet.expirationDate = fileId.Item3;
            packet.signatoryKeyPacket = getPublicKeyPacketTask.Result;
            packet.ncComment = commentResult.Item1;
            packet.userComment = commentResult.Item2;

            MatchCollection matches = Regex.Matches(signature, @"File Section\s*{\s*([^}]*)\s*}", RegexOptions.Multiline);
            string[] groups = matches.Cast<Match>().Select(match => match.Value).ToArray();

            Parallel.ForEach(groups, (element) => {
                string name = "", hash = ""; long size; FileStatut statut = FileStatut.Valid;
                try { name = element.Split("Name : ")[1].Split("\n")[0]; } catch { return; }
                try { size = (long)int.Parse(element.Split("Size : ")[1].Split("\n")[0]); } catch { size = -1; statut = FileStatut.Partial; }
                try { hash = element.Split("Hash : ")[1].Split("\n")[0]; } catch { hash = ""; }

                if (!File.Exists(dirInfo.FullName + name)) statut = FileStatut.Missing;
                if (SHAFunction.GetHash(File.ReadAllText(dirInfo.FullName + name), "SHA512", "base64") != hash) statut = FileStatut.Invalid;

                var founded = new FoundedFile
                {
                    name = name,
                    size = size,
                    statut = statut,
                };

                if ((statut == FileStatut.Invalid) || (statut == FileStatut.Missing))
                    invalidFiles++;

                files.Add(founded);
            });
        }
    }
}