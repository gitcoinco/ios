//
//  DraggableViewBackground.m
//  RKSwipeCards
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//
// Forked by Kevin Owocki on 10/14/2017
// Thanks Richard for your hard work on this.
// Posted online open source at https://github.com/gitcoinco/ios

#import "DraggableViewBackground.h"

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 386; //%%% height of the draggable card
static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize cardData; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex{

    exit(0);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];

        NSError *error;
        NSString *url_string = [NSString stringWithFormat: @"https://gitcoin.co/api/v0.1/bounties?&idx_status=submitted&order_by=-web3_created"];
        @try {
            NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
            NSMutableArray *apiResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            cardData = apiResponse;
            loadedCards = [[NSMutableArray alloc] init];
            allCards = [[NSMutableArray alloc] init];
            cardsLoadedIndex = 0;
            [self loadCards];
        }
        
        @catch ( NSException *e ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection"
                                                            message:@"Please restart the app when you've got an internet connection" delegate:self cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    return self;
}


//%%% sets up the extra buttons on the screen
-(void)setupView
{
    self.backgroundColor = [UIColor colorWithRed:0.94 green:0.96 blue:0.93 alpha:1.0]; //the gray background colors
    
    //menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 34, 22, 15)];
    //[menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    //messageButton = [[UIButton alloc]initWithFrame:CGRectMake(284, 34, 18, 18)];
    //[messageButton setImage:[UIImage imageNamed:@"messageButton"] forState:UIControlStateNormal];
    //xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 485, 59, 59)];
    //[xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    //[xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    //checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 485, 59, 59)];
    //[checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    //[checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    //[self addSubview:menuButton];
    //[self addSubview:messageButton];
    //[self addSubview:xButton];
   // [self addSubview:checkButton];
}

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
    NSDictionary*  thisCard = [cardData objectAtIndex:index];
    NSDictionary*  metadata = [thisCard objectForKey:@"metadata"];
    
    // set all information about card here
    draggableView.information.text = [thisCard objectForKey:@"title"];
    draggableView.information.numberOfLines = 3;
    draggableView.url = [thisCard objectForKey:@"github_url"];
    [draggableView sizeToFit];
    
    //keywords
    draggableView.keywords.text = [metadata objectForKey:@"issueKeywords"];
    
    //value
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:3];
    NSString * value_true = [numberFormatter stringFromNumber:[thisCard objectForKey:@"value_true"]];
    NSString * amount_native = [[value_true stringByAppendingString:@" "] stringByAppendingString:[thisCard objectForKey:@"token_name"]];
    if ([thisCard objectForKey:@"value_in_usdt"] != nil){
        NSString *value_usdt = [numberFormatter stringFromNumber:[thisCard objectForKey:@"value_in_usdt"]];
        value_usdt = [@" ( " stringByAppendingString:value_usdt];
        value_usdt = [value_usdt stringByAppendingString:@" USDT )"];
        amount_native = [amount_native stringByAppendingString:value_usdt];
    }

    
    draggableView.amount_native.text = amount_native;
    NSURL *url=[NSURL URLWithString:[thisCard objectForKey:@"avatar_url"]];
    [draggableView setImageURL:url :index];
    draggableView.delegate = self;
    
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([cardData count] > 0) {
        NSInteger numLoadedCardsCap =(([cardData count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[cardData count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[cardData count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }

}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
