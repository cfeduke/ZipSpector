//
//  MyDocument.m
//  ZipSpector
//
//  Created by Charles Feduke on 3/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

-(BOOL)readFromURL:(NSURL *)absoluteURL 
			ofType:(NSString *)typeName
			 error:(NSError **)outError {
	NSString *filename = [absoluteURL path];
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPad@"/usr/bin/zipinfo"];
	NSArray *args = [NSArray arrayWithObjects:@"-1", filename, nil];
	[task setArguments:args];
	
	NSPipe *outPipe = [[NSPipe alloc] init];
	[task setStandardOutput:outPipe];
	[outPipe release];
	
	[task launch];
	
	NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
	
	[task waitUntilExit];
	int status = [task terminationStatus];
	[task release];
	
	if (status != 0) {
		if (outError) {
			NSDictionary *eDict = [NSDictionary dictionaryWithObject:@"zipinfo failed" forKey:NSLocalizedFailureReasonErrorKey];
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:0 userInfo:eDict];
		}
		return NO;
	}
	
	NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	[filenames release];
	filenames = [[aString componentsSeparatedByString:@"\n"] retain];
	NSlog(@"filenames = %@", filenames);
	
	[aString release];
	
	[tableView reloadData];
	
	return YES;
}

-(int)numberOfRowsInTableView(NSTableView *)v {
	return [filenames count];
}

-(id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tc row:(NSInteger) row {
	return [filenames objectAtIndex:row];
}

@end
