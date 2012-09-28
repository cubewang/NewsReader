//
//  QSyncHttp.m
//  QWeiboSDK4iOS
//
//  Created on 11-1-13.
//  
//

#import "QMutableURLRequest.h"
#import "NSURL+QAdditions.h"


@implementation QMutableURLRequest


#pragma mark -
#pragma mark calss methods

+ (NSMutableURLRequest *)requestGet:(NSString *)aUrl queryString:(NSString *)aQueryString {
	NSMutableString *url = [[NSMutableString alloc] initWithString:aUrl];
	if (aQueryString) {
		[url appendFormat:@"?%@", aQueryString];
	}
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL smartURLForString:url]] autorelease];
	[request setHTTPMethod:@"GET"];
	[request setTimeoutInterval:20.0f];
	
	[url release];
	return request;
}

+ (NSMutableURLRequest *)requestPost:(NSString *)aUrl queryString:(NSString *)aQueryString {
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL smartURLForString:aUrl]] autorelease];
	[request setHTTPMethod:@"POST"];
	[request setTimeoutInterval:20.0f];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:[aQueryString dataUsingEncoding:NSUTF8StringEncoding]];
	
	return request;
}

+ (NSMutableURLRequest *)requestPostWithFile:(NSDictionary *)files url:(NSString *)aUrl queryString:(NSString *)aQueryString {
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL smartURLForString:aUrl]] autorelease];
	[request setHTTPMethod:@"POST"];
	[request setTimeoutInterval:20.0f];
	
	//generate boundary string
	CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
	
	NSData *boundaryBytes = [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *bodyData = [NSMutableData data];
	NSString *formDataTemplate = @"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@";
	
	NSDictionary *listParams = [NSURL parseURLQueryString:aQueryString];
	for (NSString *key in listParams) {
		
		NSString *value = [listParams valueForKey:key];
		NSString *formItem = [NSString stringWithFormat:formDataTemplate, boundary, key, value];
		[bodyData appendData:[formItem dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[bodyData appendData:boundaryBytes];
	 
	NSString *headerTemplate = @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: \"application/octet-stream\"\r\n\r\n";
	for (NSString *key in files) {
		
		NSString *filePath = [files objectForKey:key];
		NSData *fileData = [NSData dataWithContentsOfFile:filePath];
		NSString *header = [NSString stringWithFormat:headerTemplate, key, [[filePath componentsSeparatedByString:@"/"] lastObject]];
		[bodyData appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
		[bodyData appendData:fileData];
		[bodyData appendData:boundaryBytes];
	}
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:bodyData];
	
	return request;
}

@end
