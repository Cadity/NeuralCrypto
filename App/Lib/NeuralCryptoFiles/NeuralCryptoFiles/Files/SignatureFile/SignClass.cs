using System;
using System.Collections.Generic;
using System.IO;

namespace NeuralCryptoFiles.Files.SignatureFile
{
	public class SignClass
	{
		private SignFileParameters parameters { get; }

		public SignClass(SignFileParameters inputParam)
		{
			parameters = inputParam;
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

