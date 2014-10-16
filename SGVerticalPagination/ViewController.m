//
//  ViewController.m
//  SGVerticalPagination
//
//  Created by Sourav on 16/10/14.
//  Copyright (c) 2014 Sourav. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ViewController.h"

@interface ViewController (){
    IBOutlet UITableView *descriptionTableView;
    int pageCount ;
}

@property(nonatomic,strong)NSMutableDictionary *dictionaryCurrentSessionData;
@property(nonatomic,strong)NSMutableArray *discriptionArray;
@property (strong,nonatomic)UIActivityIndicatorView *spinner;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.center = self.view.center;
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    
    pageCount = 0;
    _dictionaryCurrentSessionData = [NSMutableDictionary dictionary];
    _discriptionArray = [[NSMutableArray alloc] init];
    
    [self getData];
}

-(void)getData{
    
    // code to download the json with NSURLSession
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    pageCount++;
    
    NSString *stringUrl = [NSString stringWithFormat:@"http://54.68.186.214:8080/myproject/data/getPaginatedData?pageNumber=%d",pageCount];
    
    [[session dataTaskWithURL:[NSURL URLWithString:stringUrl] completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *tempArray = [responseDict objectForKey:@"valuelist"];
        if (tempArray.count > 0) {
            
            NSNumber *numberOfrecords = [responseDict objectForKey:@"totalNumberOfRecords"];
            NSNumber *startPoint = [responseDict objectForKey:@"startingPoint"];
            
            NSMutableDictionary *currentSession = [[NSMutableDictionary alloc] init];
            [currentSession setValue:startPoint  forKey:@"start_limit"];
            [currentSession setValue:numberOfrecords forKey:@"total_records"];
            [_dictionaryCurrentSessionData setValue:currentSession forKey:@"SessionInfo"];
            
            [tempArray enumerateObjectsUsingBlock:^(NSDictionary *obj,NSUInteger idx, BOOL *stop){
                [_discriptionArray addObject:obj];
            }];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [descriptionTableView reloadData];
                [_spinner stopAnimating];
                [descriptionTableView setHidden:NO];
                
            });
            
            
        }
        
        
        
    }] resume];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    NSDictionary *tempDict = [_dictionaryCurrentSessionData objectForKey:@"SessionInfo"];
    int startValue = (int)[[tempDict objectForKey:@"start_limit"] integerValue];
    int totalRecords = (int)[[tempDict objectForKey:@"total_records"] integerValue];
    
    
    // check if the startValue is less than toatlrecords
    // Since we are getting 10 strings array each time so that is why i am adding 9
    
    if (startValue+9 < totalRecords) {
        return 2;
    }else{
        
        return 1;
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    
    // This snippet is necessary because first time _discriptionArray will be null
    if(_discriptionArray == nil){
        return 0;
    }
    
    
    if (section == 0) {
        return _discriptionArray.count;
        
    }else{
        
        // this will show "loading" text in a row
        return 1;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        UILabel *descriptionText = (UILabel *)[cell viewWithTag:1];
        descriptionText.text = [_discriptionArray objectAtIndex:indexPath.row];
        
        return cell;
        
    }else{
        
        UITableViewCell *cell;
        
        NSString *CellIdentifier = @"";
        CellIdentifier = [CellIdentifier stringByAppendingFormat:@"Cell%ld", (long)indexPath.section];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Loading...";
        cell.textLabel.font = [UIFont fontWithName:@"PaktSemiBold" size:17];
        [self getData];
        return cell;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end

