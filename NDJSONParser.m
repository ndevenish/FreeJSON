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
#import "NSScanner+parsing.h"

@implementation NDJSONParser

- (id)initWithString:(NSString*)data
{
  self = [super init];
  if (!self) return nil;
  
  self.data = data;
  self.scanner = [NSScanner scannerWithString:data];
  
  return self;
}

- (NSString*)parseString
{
  NSMutableString *string = [NSMutableString string];
  // Scan until " or "\"
  NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\"\\"];

  while (YES) {
    NSString *scanned;
    [self.scanner scanUpToCharactersFromSet:set intoString:&scanned];
    [string appendString:scanned];
    // We have found either the end, or a divider
    unichar next = [self.scanner nextCharacter];
//    [string appendFormat:@"%C",next];
    if (next == '"') {
      // We are at the end of the string!
      break;
    } else if (next == '\\') {
      // An escape.. parse this
    } else {
      NSAssert(NO, @"Unknown position in string parsing");
    }
  }
  return string;
}

- (NSArray*)parseArray
{
  return [NSArray array];
}

- (NSDictionary*)readKeyValuePair
{
  return [NSDictionary dictionary];
}

- (NSDictionary*)parseObject
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  return dict;
}

- (id)parseValue
{
  unichar firstChar = [self.scanner nextCharacter];
  if (firstChar == '[') {
    return [self parseArray];
  } else if (firstChar == '{') {
    return [self parseObject];
  } else if (firstChar == '"') {
    return [self parseString];
  } else {
    // Parse a value... number, true, false, null
    NSString *contents;
    NSMutableCharacterSet *separators = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
    [self.scanner scanUpToCharactersFromSet:separators intoString:&contents];
    
    [separators addCharactersInString:@","];
  }
  return nil;
}

- (id)parse
{
  return [self parseValue];
//  NSLog(@"First Character: %C", [self.scanner nextCharacter]);
//  return nil;
}

@end
