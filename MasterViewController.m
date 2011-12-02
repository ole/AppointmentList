//
//  MasterViewController.m
//  AppointmentList
//
//  Created by Ole Begemann on 01.12.11.
//  Copyright (c) 2011 Ole Begemann. All rights reserved.
//

#import "MasterViewController.h"


@interface MasterViewController ()

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
- (NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate;

@end



@implementation MasterViewController

@synthesize sections;
@synthesize sortedDays;
@synthesize sectionDateFormatter;
@synthesize cellDateFormatter;


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSDate *now = [NSDate date];
    NSDate *startDate = [self dateAtBeginningOfDayForDate:now];
    NSDate *endDate = [self dateByAddingYears:1 toDate:startDate];
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSPredicate *searchPredicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *events = [eventStore eventsMatchingPredicate:searchPredicate];
    
    self.sections = [NSMutableDictionary dictionary];
    for (EKEvent *event in events) 
    {
        // Reduce event start date to date components (year, month, day)
        NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event.startDate];
        
        // If we don't yet have an array to hold the events for this day, create one
        NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            
            // Use the reduced date as dictionary key to later retrieve the event list this day
            [self.sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        
        // Add the event to the list for this day
        [eventsOnThisDay addObject:event];
    }
    
    // Create a sorted list of days
    NSArray *unsortedDays = [self.sections allKeys];
    self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];

    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Date Calculations

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back       
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

- (NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate
{
    // Use the user's current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setYear:numberOfYears];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    return newDate;
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    return [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"EventTitleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    EKEvent *event = [eventsOnThisDay objectAtIndex:indexPath.row];
    
    cell.textLabel.text = event.title;
    if (event.allDay) {
        cell.detailTextLabel.text = @"all day";
    } else {
        cell.detailTextLabel.text = [self.cellDateFormatter stringFromDate:event.startDate];
    }
    return cell;
}

@end
