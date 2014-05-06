/*
 * Created by Richard North on 06/05/2014.
 * (c) Richard North 2014
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "RNPlaceholderDataSource.h"
#import "RNPlaceholderTableViewCell.h"
#import "RNPlaceholderEntry.h"
#import "RNPlaceholderCollectionViewCell.h"

static const int kRNPlaceholderDataSourceNumberOfImagesPerGender = 50;

@interface RNPlaceholderDataSource ()

@property(nonatomic, strong) NSArray *maleFirstNames;
@property(nonatomic, strong) NSArray *femaleFirstNames;
@property(nonatomic, strong) NSArray *lastNames;

@property(nonatomic) dispatch_once_t self_once_predicate;
@end

@implementation RNPlaceholderDataSource

//------------------------------------------------------------------------------
#pragma mark - Internal random data generation
//------------------------------------------------------------------------------

- (NSArray *)randomizedEntries {

    dispatch_once(&_self_once_predicate, ^{
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"names" ofType:@"json"];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
        NSError *error;
        NSArray *data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

        for (NSArray *item in data) {
            if ([item[0][@"country"] isEqualToString:[self namesLocaleName]]) {
                _maleFirstNames = item[1];
                _femaleFirstNames = item[2];
                _lastNames = item[3];
            }
        }

        _randomizedEntries = [[NSMutableArray alloc] init];

        int imageRandomInitializerOffset = abs(arc4random());
        for (int i = 0; i < self.count; i++) {

            RNPlaceholderEntry *entry = [[RNPlaceholderEntry alloc] init];

            if (arc4random() % 2 == 0) {
                entry.gender = Male;
                entry.firstName = [self pickRandomFrom:_maleFirstNames];
                entry.faceImage = [self pickImageWithPrefix:@"male" index:i + imageRandomInitializerOffset];
            } else {
                entry.gender = Female;
                entry.firstName = [self pickRandomFrom:_femaleFirstNames];
                entry.faceImage = [self pickImageWithPrefix:@"female" index:i + imageRandomInitializerOffset];
            }

            entry.lastName = [self pickRandomFrom:_lastNames];

            [(NSMutableArray *) _randomizedEntries addObject:entry];
        }
    });

    return _randomizedEntries;
}

- (id)pickRandomFrom:(NSArray *)values {
    return [values objectAtIndex:(arc4random() % [values count])];
}

- (UIImage *)pickImageWithPrefix:(NSString *)prefix index:(int)index {
    NSString *imageName = [NSString stringWithFormat:@"%@%02d.jpg", prefix, index % kRNPlaceholderDataSourceNumberOfImagesPerGender];

    UIImage *image = [UIImage imageNamed:imageName];
    NSAssert(image != nil, @"Image should not be nil! Name used was %@", imageName);

    return image;
}

//------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource methods
//------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RNPlaceholderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];

    if (!cell) {
        [NSException raise:@"ConfigurationException" format:@"Could not find a prototype table view cell with identifier %@. Please configure the Reuse Identifier of the prototype cell and try again.", self.cellIdentifier];
    }

    if (![cell isKindOfClass:[RNPlaceholderTableViewCell class]]) {
        [NSException raise:@"ConfigurationException" format:@"Table view cell must be of type RNPlaceholderTableViewCell but actually got a %@. Please configure the class of the prototype cell and try again.", [cell class]];
    }

    RNPlaceholderEntry *entry = [self.randomizedEntries objectAtIndex:indexPath.row];

    [cell populateForEntry:entry];

    return cell;
}

//------------------------------------------------------------------------------
#pragma mark - UICollectionViewDataSource methods
//------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RNPlaceholderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];

    if (!cell) {
        [NSException raise:@"ConfigurationException" format:@"Could not find a prototype colection view cell with identifier %@. Please configure the Reuse Identifier of the prototype cell and try again.", self.cellIdentifier];
    }

    if (![cell isKindOfClass:[RNPlaceholderCollectionViewCell class]]) {
        [NSException raise:@"ConfigurationException" format:@"Collection view cell must be of type RNPlaceholderCollectionViewCell but actually got a %@. Please configure the class of the prototype cell and try again.", [cell class]];
    }

    RNPlaceholderEntry *entry = [self.randomizedEntries objectAtIndex:indexPath.row];

    [cell populateForEntry:entry];

    return cell;
}


//------------------------------------------------------------------------------
#pragma mark - Safe-default property getters
//------------------------------------------------------------------------------
- (NSString *)cellIdentifier {
    if (_cellIdentifier) {
        return _cellIdentifier;
    } else {
        return @"Cell";
    }
}

- (NSInteger)count {
    if (_count) {
        return _count;
    } else {
        return 50;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Localization support
//------------------------------------------------------------------------------
- (NSString *)namesLocaleName {
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];

    if ([localeIdentifier isEqualToString:@"en_GB"]) {
        return @"England";
    } else if ([localeIdentifier hasPrefix:@"sq_"]) {
        return @"Albania";
    } else if ([localeIdentifier isEqualToString:@"es_AR"]) {
        return @"Argentina";
    } else if ([localeIdentifier isEqualToString:@"pt_BR"]) {
        return @"Brazil";
    } else if ([localeIdentifier hasSuffix:@"_CA"]) {
        return @"Canada";
    } else if ([localeIdentifier hasSuffix:@"_CN"] || [localeIdentifier hasSuffix:@"_HK"] || [localeIdentifier hasSuffix:@"_MO"]) {
        return @"China";
    } else if ([localeIdentifier hasPrefix:@"da_"]) {
        return @"Denmark";
    } else if ([localeIdentifier hasPrefix:@"fi_"]) {
        return @"Finland";
    } else if ([localeIdentifier hasPrefix:@"de_"]) {
        return @"Germany";
    } else if ([localeIdentifier hasPrefix:@"hu_"]) {
        return @"Hungary";
    } else if ([localeIdentifier hasSuffix:@"_IN"]) {
        return @"India";
    } else if ([localeIdentifier hasPrefix:@"he_"]) {
        return @"Israel";
    } else if ([localeIdentifier hasPrefix:@"it_"]) {
        return @"Italy";
    } else if ([localeIdentifier hasSuffix:@"_MA"]) {
        return @"Morocco";
    } else if ([localeIdentifier hasPrefix:@"_NZ"]) {
        return @"New Zealand";
    } else if ([localeIdentifier hasPrefix:@"pl_"]) {
        return @"Poland";
    } else if ([localeIdentifier hasPrefix:@"ro_"]) {
        return @"Romania";
    } else if ([localeIdentifier hasPrefix:@"ru_"]) {
        return @"Russia";
    } else if ([localeIdentifier hasPrefix:@"es_"]) {
        return @"Spain";
    } else if ([localeIdentifier hasPrefix:@"sv_"]) {
        return @"Sweden";
    } else {
        return @"United States";
    }
}

@end