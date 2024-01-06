# OpenSSL For iOS Static XCFramework

## Example

```Objective-C

    NSString* data = @"Hello";
    NSString* key = @"World!";
    
    NSString* encrypted = [AESUtil encrypt:data withKey:key];
    
    NSLog(@"encrypted %@", encrypted); // sox6DAvpLrudYwqjvBa/fg==
    
    NSString* decrypted = [AESUtil decrypt:encrypted withKey:key];
    
    NSLog(@"decrypted %@", decrypted);

```
