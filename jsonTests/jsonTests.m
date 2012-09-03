// Copyright ©2012 Nicholas Devenish
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met: 
// 
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NDJSONParser.h"

#import <SenTestingKit/SenTestingKit.h>

@interface jsonTests : SenTestCase

@end

@implementation jsonTests

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testStringValues
{
  NDJSONParser *parser = [[NDJSONParser alloc] initWithString:@"\"something\""];
  STAssertEqualObjects(@"something", [parser parse], @"String returned");
  
  parser = [[NDJSONParser alloc] initWithString:@"\"somet\\\"hing\""];
  STAssertEqualObjects(@"somet\"hing", [parser parse], @"String returned");
  
}

- (void)testObject
{
  
}

- (void)testArray
{
  
}

- (void)testKeyword
{
  NDJSONParser *parser = [[NDJSONParser alloc] initWithString:@"true"];
  STAssertEqualObjects([NSNumber numberWithBool:YES], [parser parse], @"Correct keyword");
  parser = [[NDJSONParser alloc] initWithString:@"false"];
  STAssertEqualObjects([NSNumber numberWithBool:NO], [parser parse], @"Correct keyword");
  parser = [[NDJSONParser alloc] initWithString:@"null"];
  STAssertEqualObjects([NSNull null], [parser parse], @"Correct keyword");
}

- (void)testNumber
{
  NDJSONParser *parser = [[NDJSONParser alloc] initWithString:@"1"];
  STAssertEqualObjects([NSNumber numberWithInt:1], parser.parse, @"Number parsing");
  
  parser = [[NDJSONParser alloc] initWithString:@"1.1"];
  STAssertEqualObjects([NSNumber numberWithDouble:1.1], parser.parse, @"Number parsing");
  
  parser = [[NDJSONParser alloc] initWithString:@".1"];
  STAssertEqualObjects([NSNumber numberWithDouble:0.1], parser.parse, @"Number parsing");
  
  parser = [[NDJSONParser alloc] initWithString:@"-443"];
  STAssertEqualObjects([NSNumber numberWithInt:-443], parser.parse, @"Number parsing");
  
  parser = [[NDJSONParser alloc] initWithString:@"2e3"];
  STAssertEqualObjects([NSNumber numberWithDouble:2e3], parser.parse, @"Number parsing");

}
@end
