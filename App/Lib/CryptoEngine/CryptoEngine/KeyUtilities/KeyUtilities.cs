using System;
namespace CryptoEngine.KeyUtilities
{
	public static class KeyUtilities
	{
		public static string TestKeyValidity(DateTime expirationTime)
		{
            if (expirationTime < DateTime.UtcNow.AddMilliseconds(1000))
                return "N'expire pas";
            else
                return expirationTime.ToString("dd/MM/yyyy HH:mm");
        }

        public static string GetAlgorithm(string algorithm)
        {
            return algorithm switch
            {
                "RsaGeneral" => "RSA Chiffrant, RSA Signant",
                _ => "Other"
            };
        }
    }
}

