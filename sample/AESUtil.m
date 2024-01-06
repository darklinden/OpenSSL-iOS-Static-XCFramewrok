#import "AESUtil.h"
#import <OpenSSL/evp.h>

#ifdef DEBUG
#define DLog(fmt,...) NSLog((@"[DLog]: " fmt), ##__VA_ARGS__);
#else
#define DLog(fmt,...)
#endif

@implementation AESUtil

+ (void)pading:(nonnull NSString*)src toSize:(const int)size des:(unsigned char*)des
{
    NSData* srcBytes = [src dataUsingEncoding:NSUTF8StringEncoding];
    unsigned long len = srcBytes.length;
    
    if (len >= size) {
        memcpy(des, srcBytes.bytes, size);
        return;
    }
    
    memcpy(des, srcBytes.bytes, len);
    
    unsigned char c = size - len;
    memset(des + len, c, c);
}

void LogBytes(NSString* tag, const unsigned char* bytes, unsigned long len)
{
    NSMutableString* log = [NSMutableString string];
    for (unsigned long i=0; i < len; i++) {
        [log appendFormat:@"%.2X ", bytes[i]];
    }
    DLog(@"%@ %@", tag, log);
}

void LogData(NSString* tag, NSData* data)
{
    LogBytes(tag, data.bytes, data.length);
}

+ (nullable NSString*)encrypt:(nonnull NSString*)message withKey:(nonnull NSString*)strkey
{
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    
    // prepare key
    unsigned char key[32] = {0};
    [self pading:strkey toSize:32 des:&key[0]];
    LogBytes(@"key", key, 32);
    
    unsigned char iv[16] = {0};
    memset(iv, 0, 16);
    LogBytes(@"iv", iv, 16);
    
    int result;
    
    if ((result = EVP_EncryptInit(ctx, EVP_aes_256_cbc(), key, iv)) < 0) {
        DLog(@"EVP_EncryptInit %d", result);
        return nil;
    }
     
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    const unsigned char* bytes = data.bytes;
    unsigned long datalen = data.length;
    
    LogData(@"inData", data);
    
    int buffer_len = 256;
    unsigned char buffer_out[512] = { 0x0 };
    NSMutableData* outData = [NSMutableData data];
    
    int outlen = 0;
    int index = 0;
    while (index < datalen) {
        int inlen = (int)(datalen - index);
        if (inlen > buffer_len) inlen = buffer_len;
        
        if ((result = EVP_EncryptUpdate(ctx, buffer_out, &outlen, bytes + index, inlen)) < 0) {
            DLog(@"EVP_EncryptUpdate %d", result);
            return nil;
        }
        
        [outData appendBytes:buffer_out length:outlen];
        index += inlen;
    }
     
    if ((result = EVP_EncryptFinal(ctx, buffer_out, &outlen)) < 0) {
        DLog(@"EVP_EncryptInit %d", result);
        return nil;
    }
    
    EVP_CIPHER_CTX_free(ctx);
    
    [outData appendBytes:buffer_out length:outlen];
    
    LogBytes(@"iv", iv, 16);
    LogData(@"outData", outData);
    return [outData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (nullable NSString*)decrypt:(nonnull NSString*)base64Data withKey:(nonnull NSString*)strkey
{
    EVP_CIPHER_CTX *ctx = EVP_CIPHER_CTX_new();
    
    // prepare key
    unsigned char key[32] = {0};
    [self pading:strkey toSize:32 des:&key[0]];
    LogBytes(@"key", key, 32);
    
    unsigned char iv[16] = {0};
    memset(iv, 0, 16);
    LogBytes(@"iv", iv, 16);
    
    int result;
    
    if ((result = EVP_DecryptInit(ctx, EVP_aes_256_cbc(), key, iv)) < 0) {
        DLog(@"EVP_DecryptInit %d", result);
        return nil;
    }
    
    NSData* data = [[NSData alloc] initWithBase64EncodedString:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    const unsigned char* bytes = data.bytes;
    unsigned long datalen = data.length;
    
    LogData(@"inData", data);
    
    int buffer_len = 256;
    unsigned char buffer_out[512] = { 0x0 };
    NSMutableData* outData = [NSMutableData data];
    
    int outlen = 0;
    int index = 0;
    while (index < datalen) {
        int inlen = (int)(datalen - index);
        if (inlen > buffer_len) inlen = buffer_len;
        
        if ((result = EVP_DecryptUpdate(ctx, buffer_out, &outlen, bytes + index, inlen)) < 0) {
            DLog(@"EVP_DecryptUpdate %d", result);
            return nil;
        }
        
        [outData appendBytes:buffer_out length:outlen];
        index += inlen;
    }
    
    if ((result = EVP_DecryptFinal(ctx, buffer_out, &outlen)) < 0) {
        DLog(@"EVP_DecryptFinal %d", result);
        return nil;
    }
    
    EVP_CIPHER_CTX_free(ctx);
    
    [outData appendBytes:buffer_out length:outlen];
    
    LogBytes(@"iv", iv, 16);
    LogData(@"outData", outData);
    
    return [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
}

@end
