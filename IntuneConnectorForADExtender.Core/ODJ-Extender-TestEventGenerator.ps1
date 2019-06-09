New-EventLog -LogName "ODJ Connector Service" -Source "ODJ Connector Service Source"

Write-EventLog -LogName "ODJ Connector Service" -Source "ODJ Connector Service Source" -EntryType Information -EventId 30130 -Message '{
     "Metric":{
         "Dimensions":{
             "RequestId":"d302cfe6-b60f-4d56-9f3a-2abbd89c6882",
             "DeviceId":"59c1b762-1852-46e0-9ebe-439aab2d17f0",
             "DomainName":"XXXXXX",
             "MachineName":"HYBDcggLnwOWnRC",
             "BlobDataLength":"1312",
             "InstanceId":"3B530FA1-F32B-4D61-BAD4-D7211D8603B3",
             "DiagnosticCode":"0x00000000",
             "DiagnosticText":"Successful"
         },
         "Name":"RequestOfflineDomainJoinBlob_Success",
         "Value":0
     }}'
