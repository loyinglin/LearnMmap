//
//  ViewController.m
//  LearnMmap
//
//  Created by loyinglin on 2019/7/8.
//  Copyright © 2019 Loying. All rights reserved.
//

#import "ViewController.h"
#import <sys/mman.h>
#import <sys/stat.h>

int MapFile(const char * inPathName, void ** outDataPtr, size_t * outDataLength, size_t appendSize)
{
    int outError;
    int fileDescriptor;
    struct stat statInfo;
    
    // Return safe values on error.
    outError = 0;
    *outDataPtr = NULL;
    *outDataLength = 0;
    
    // Open the file.
    fileDescriptor = open( inPathName, O_RDWR, 0 );
    if( fileDescriptor < 0 )
    {
        outError = errno;
    }
    else
    {
        // We now know the file exists. Retrieve the file size.
        if( fstat( fileDescriptor, &statInfo ) != 0 )
        {
            outError = errno;
        }
        else
        {
            ftruncate(fileDescriptor, statInfo.st_size + appendSize);
            fsync(fileDescriptor);
            *outDataPtr = mmap(NULL,
                               statInfo.st_size + appendSize,
                               PROT_READ|PROT_WRITE,
                               MAP_FILE|MAP_SHARED,
                               fileDescriptor,
                               0);
            if( *outDataPtr == MAP_FAILED )
            {
                outError = errno;
            }
            else
            {
                // On success, return the size of the mapped file.
                *outDataLength = statInfo.st_size;
            }
        }
        
        // Now close the file. The kernel doesn’t use our file descriptor.
        close( fileDescriptor );
    }
    
    return outError;
}


void ProcessFile(const char * inPathName)
{
    size_t dataLength;
    void * dataPtr;
    char *appendStr = " append_key";
    int appendSize = (int)strlen(appendStr);
    if( MapFile(inPathName, &dataPtr, &dataLength, appendSize) == 0) {
        dataPtr = dataPtr + dataLength;
        memcpy(dataPtr, appendStr, appendSize);
        // Unmap files
        munmap(dataPtr, appendSize + dataLength);
    }
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"test.data"];
    NSLog(@"path: %@", path);
    NSString *str = @"test str";
    [str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    ProcessFile(path.UTF8String);
    NSString *result = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"result:%@", result);
}


@end
