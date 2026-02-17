PS C:\Users\Administrator> # Define parameters
PS C:\Users\Administrator> $certificateParams = @{
>>     Type = "SSLServerAuthentication"
>>     Subject = "CN=$env:COMPUTERNAME"
>>     DnsName = @("$($env:COMPUTERNAME)", $([System.Net.Dns]::GetHostEntry('').HostName), 'localhost')
>>     KeyAlgorithm = "RSA"
>>     KeyLength = 2048
>>     HashAlgorithm = "SHA256"
>>     TextExtension = "2.5.29.37={text}1.3.6.1.5.5.7.3.1"
>>     NotAfter = (Get-Date).AddMonths(36)
>>     KeySpec = "KeyExchange"
>>     Provider = "Microsoft RSA SChannel Cryptographic Provider"
>>     CertStoreLocation = "cert:\LocalMachine\My"
>> }
PS C:\Users\Administrator>
PS C:\Users\Administrator> # Call the cmdlet
PS C:\Users\Administrator> New-SelfSignedCertificate @certificateParams


   PSParentPath: Microsoft.PowerShell.Security\Certificate::LocalMachine\My

Thumbprint                                Subject
----------                                -------
6C6F3F42FCB3B1BAC5858252EC32F9A23F1ED55D  CN=AREA51