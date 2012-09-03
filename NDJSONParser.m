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
  
  self.scanner = [NSScanner scannerWithString:data];
  
  return self;
}

- (NSNumber*)parseNumberFromString:(NSString*)string
{
  NSScanner *scanner = [NSScanner scannerWithString:string];
  
  NSInteger intValue;
  [scanner scanInteger:&intValue];
  if (scanner.isAtEnd) {
    return [NSNumber numberWithInteger:intValue];
  }
  
  double dubValue;
  scanner.scanLocation = 0;
  [scanner scanDouble:&dubValue];
  if (scanner.isAtEnd) {
    return [NSNumber numberWithDouble:dubValue];
  }
  
  NSAssert(NO, @"Could not parse value");
  return nil;
}

- (NSString*)parseStringEscape
{
  NSString *ret;
  unichar next = [self.scanner nextCharacter];
  if (next == '"') {
    ret =  @"\"";
  } else if (next == '\\') {
    ret =  @"\\";
  } else if (next == '/') {
    ret =  @"/";
  } else if (next == 'b') {
    ret =  @"\b";
  } else if (next == 'f') {
    ret =  @"\f";
  } else if (next == 'n') {
    ret =  @"\n";
  } else if (next == 'r') {
    ret =  @"\r";
  } else if (next == 't') {
    ret =  @"\t";
  } else if (next == 'u') {
    NSAssert(0, @"Unicode escape not yet supported");
  } else {
    NSAssert(0, @"Unrecognised unicode escape");
  }
  return ret;
}

- (NSString*)parseStringWithLeading
{
  unichar next = self.scanner.nextCharacter;
  if (!next == '"') return nil;
  return self.parseString;
}

- (NSString*)parseString
{
  NSMutableString *string = [NSMutableString string];
  // Scan until " or "\"
  NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\"\\"];

  while (YES) {
    NSString *scanned;
    [self.scanner scanUpToCharactersFromSet:set intoString:&scanned];
    if (scanned) {
      [string appendString:scanned]; 
    }
    // We have found either the end, or a divider
    unichar next = [self.scanner nextCharacter];

    if (next == '"') {
      // We are at the end of the string!
      break;
    } else if (next == '\\') {
      [string appendString:[self parseStringEscape]];
    } else {
      return nil;
    }
  }
  return string;
}

- (NSArray*)parseArray
{
  NSMutableArray *array = [NSMutableArray array];

  // Loop until we close the array
  unichar next = self.scanner.peekNextCharacter;
  while (next != ']') { // && !self.scanner.isAtEnd
    // Read a value
    [array addObject:self.parseValue];

    // If we don't have a comma or ], fail
    next = self.scanner.nextCharacter;
    NSAssert(next == ',' || next == ']', @"Invalid next character");
  }
  return array;
}

- (NSDictionary*)readKeyValuePair
{
  NSString *key = [self parseStringWithLeading];
  unichar divider = [self.scanner nextCharacter];
  NSAssert(divider == ':', @"Invalid dictionary divider");
  id value = [self parseValue];
  NSAssert(value, @"Invalid value!");
  
  return @{key : value};
}

- (NSDictionary*)parseObject
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  unichar next = self.scanner.peekNextCharacter;
  while (next != '}') {
    // Read a value pair
    [dict addEntriesFromDictionary:[self readKeyValuePair]];
    // If we don't have a comma or }, fail
    next = self.scanner.nextCharacter;
    NSAssert(next == ',' || next == '}', @"Invalid next character");
  }
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
    NSMutableCharacterSet *separators = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
    [separators addCharactersInString:@",]}"];
    NSString *contents;
    [self.scanner scanUpToCharactersFromSet:separators intoString:&contents];
    contents = [NSString stringWithFormat:@"%C%@", firstChar, contents ? contents : @""];
    // Is this value any of the standard tokens?
    if ([contents isEqualToString:@"true"]) {
      return [NSNumber numberWithBool:YES];
    } else if ([contents isEqualToString:@"false"]) {
      return [NSNumber numberWithBool:NO];
    } else if ([contents isEqualToString:@"null"]) {
      return [NSNull null];
    }
    // We MUST have a number left, otherwise error
    // Try to parse a number
    NSNumber *number = [self parseNumberFromString:contents];
    NSAssert(number, @"Number parsed correctly");
    return number;
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
