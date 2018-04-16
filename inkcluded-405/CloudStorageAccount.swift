//
//  CloudStorageAccount.swift
//  inkcluded-405
//
//  Created by Nancy on 3/12/17.
//  Copyright © 2017 Boba. All rights reserved.
//

import Foundation
import AZSClient

class CloudStorageAccount: CloudStorageAccountProtocol {
    var azsAccount: AZSCloudStorageAccount?
    
    required init(){
        do {
            try azsAccount = AZSCloudStorageAccount(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=stylofork;AccountKey=CPjRfhP3Xy5S2ojQwQAw628wlaNwokgwmIhdNQxL2K2esSDqYcSlBhLkYeaVyGQEvviBdYYPOClI6FFUZ4kZXA==")
        }
        catch {
            print("unable to create azure storage account")
        }
    }
    
    func getBlobStorageClient() -> BlobClientProtocol {
        return BlobClient(client: (azsAccount?.getBlobClient())!)
    }
}
