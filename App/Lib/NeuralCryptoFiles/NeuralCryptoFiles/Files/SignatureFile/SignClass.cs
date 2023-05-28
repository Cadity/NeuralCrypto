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
using iText.Kernel.Pdf;
using iText.Layout;
using iText.Layout.Element;
using iText.Layout.Properties;
using System.Globalization;
using CryptoEngine.KeyUtilities;
using System.Net;

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

// Make PDF File
namespace NeuralCryptoFiles.Files.SignatureFile
{
    public static class SignFilePDF
    {
        public static void Make(string path, SignFilePacket packet)
        {
            PdfWriter writer = new PdfWriter(path);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            foreach (var element in Title_And_Intro()) document.Add(element);
            foreach (var element in Signature_Info(packet)) document.Add(element);
            foreach (var element in Signatory_Key_Info(packet)) document.Add(element);
            foreach (var element in File_Report(packet)) document.Add(element);

            document.Close();
        }

        private static List<Paragraph> Title_And_Intro()
        {
            var list = new List<Paragraph>();
            list.Add(new Paragraph("Rapport d'analyse du fichier de Signature").SetFontSize(15).SetTextAlignment(TextAlignment.CENTER));

            list.Add(new Paragraph("Rapport émis le " + DateTime.Now.ToString("dddd d MMMM yyyy à HH:mm", new CultureInfo("fr-FR")) + " par NeuralCrypto.").SetFontSize(11));

            return list;
        }

        private static List<Paragraph> Signature_Info(SignFilePacket packet)
        {
            var list = new List<Paragraph>();

            list.Add(new Paragraph("1. Détails de la signature").SetFontSize(13));

            var expirationStatut = "";
            if (packet.expirationDate > packet.creationDate)
                expirationStatut = " (Valide à cette date)";
            else
                expirationStatut = " (Expiré)";

            var content = "Auteur de la signature : " + packet.author + "\n" +
                "Date d'émission : " + packet.creationDate.ToString("dddd d MMMM yyyy à HH:mm", new CultureInfo("fr-FR")) + "\n" +
                "Date d'expiration : " + packet.expirationDate.ToString("dddd d MMMM yyyy à HH:mm", new CultureInfo("fr-FR")) + expirationStatut + "\n" +
                "Version de NeuralCrypto à l'édition de la signature : " + packet.ncVersion + "\n" +
                "Algorithme de hashage utilisé : " + packet.signatureFunction + " (Hash vérifié et valide)";

            list.Add(new Paragraph(content).SetFontSize(11).SetMultipliedLeading(1f));

            list.Add(new Paragraph("Commentaire généré par le logiciel").SetItalic().SetTextAlignment(TextAlignment.CENTER).SetFontSize(11));
            list.Add(new Paragraph(packet.ncComment).SetFontSize(11));

            list.Add(new Paragraph("Commentaire du Signataire").SetItalic().SetTextAlignment(TextAlignment.CENTER).SetFontSize(11));
            list.Add(new Paragraph(packet.userComment).SetFontSize(11));

            return list;
        }

        private static List<Paragraph> Signatory_Key_Info(SignFilePacket packet)
        {
            var list = new List<Paragraph>();

            list.Add(new Paragraph("2. Détails de la clé publique du signataire").SetFontSize(13));

            string replaceNoneContent(string content)
            {
                return content switch
                {
                    "none" => "Non",
                    _ => content,
                };
            }

            string verifyExpirationDate(DateTime time)
            {
                if (time < DateTime.UtcNow.AddMilliseconds(1000))
                    return "N'expire pas";
                else
                    return time.ToString("dd/MM/yyyy HH:mm");
            }

            string getAlgorithm(string algorithm)
            {
                return algorithm switch
                {
                    "RsaGeneral" => "RSA Chiffrant, RSA Signant",
                    _ => "Autre"
                };
            }

            var content = "Nom de la clé : " + packet.signatoryKeyPacket.username + "\n" +
                "Adresse-mail associée à la clé " + replaceNoneContent(packet.signatoryKeyPacket.usermail) + "\n" +
                "Commentaire de la clé : " + replaceNoneContent(packet.signatoryKeyPacket.keycomment) + "\n" +
                "Algorithme de la clé : " + KeyUtilities.GetAlgorithm(packet.signatoryKeyPacket.algorithm) + "\n" +
                "Taille de la clé : " + packet.signatoryKeyPacket.keySize + " bits\n" +
                "Date de création de la clé : " + packet.signatoryKeyPacket.creationTime.ToString("dd/MM/yyyy à HH:mm") + "\n" +
                "Date d'expiration de la clé : " + KeyUtilities.TestKeyValidity(packet.signatoryKeyPacket.expirationDate) + "\n" +
                "Empreinte de clé publique : " + packet.signatoryKeyPacket.masterKeyFingerPrint;

            list.Add(new Paragraph(content).SetFontSize(11).SetMultipliedLeading(1f));

            return list;
        }

        private static List<Paragraph> File_Report(SignFilePacket packet)
        {
            var list = new List<Paragraph>();

            list.Add(new Paragraph("3. Résultat d'analyse du fichier de signature").SetFontSize(13));

            list.Add(new Paragraph("Fichiers localisés dans le fichier : \n")
                .Add(new Tab()).Add("Nombre de fichiers total : " + packet.files.Count)
                .Add(new Tab()).Add("Nombre de fichiers ayant reçu le statut Valide : " + (packet.files.Count - packet.invalidFiles)).SetFontSize(11).SetMultipliedLeading(1f));

            return list;
        }

    }
}