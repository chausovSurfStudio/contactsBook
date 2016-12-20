//
//  BCTContactViewController.m
//  BookContacts
//
//  Created by Chausov Alexander on 20/12/16.
//  Copyright © 2016 Chausov Alexander. All rights reserved.
//

#import "BCTContactViewController.h"
#import "RPFloatingPlaceholderTextField.h"
#import "BCTThemeConstant.h"
#import "FrameAccessor.h"
#import "AlertViewController.h"
#import "BCTValidator.h"

#import "BCTDataBaseManager.h"
#import "BCTContact.h"
#import "BCTPhoneNumber.h"

#import "UIButton+CustomStyle.h"

@interface BCTContactViewController ()

@property (nonatomic, strong) IBOutlet RPFloatingPlaceholderTextField *nameTextField;
@property (nonatomic, strong) IBOutlet RPFloatingPlaceholderTextField *surnameTextField;
@property (nonatomic, strong) IBOutlet RPFloatingPlaceholderTextField *phoneTextField;
@property (nonatomic, strong) IBOutlet RPFloatingPlaceholderTextField *extraPhoneTextField;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *likedLabel;
@property (nonatomic, strong) IBOutlet UISwitch *likedSwitch;
@property (nonatomic, strong) IBOutlet UIButton *saveButon;

@property (nonatomic, strong) BCTContact *contact;

@end

@implementation BCTContactViewController

- (instancetype)initWithContact:(BCTContact *)contact {
    self = [super init];
    if (self) {
        self.contact = contact;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fillTextField];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.height + 30.0);
    
}

- (void)fillTextField {
    if (self.contact) {
        self.nameTextField.text = self.contact.name;
        self.surnameTextField.text = self.contact.surname;
        self.phoneTextField.text = self.contact.mainPhoneNumber.phoneNumber;
        BCTPhoneNumber *extraPhone = [[self.contact.addedPhoneNumbers allObjects] firstObject];
        if (extraPhone) {
            self.extraPhoneTextField.text = extraPhone.phoneNumber;
        }
    }
}

- (void)setStyle {
    self.scrollView.backgroundColor = mainBackgroundThemeNrmColor;
    
    NSArray <RPFloatingPlaceholderTextField *> *textFields = @[self.nameTextField, self.surnameTextField, self.phoneTextField, self.extraPhoneTextField];
    for (RPFloatingPlaceholderTextField *textField in textFields) {
        textField.textColor = mainTextNrmColor;
        textField.tintColor = extraTextNrmColor;
        textField.floatingLabelActiveTextColor = extraTextNrmColor;
    }
    self.likedLabel.textColor = mainTextNrmColor;
    
    [self.saveButon setSaveButtonStyle];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - Action
- (IBAction)saveButtonPress:(UIButton *)sender {
    [self saveAction];
}

- (void)saveAction {
    BOOL validField = [self validateFieldAndShowError];
    if (validField) {
        NSString *name = [[BCTValidator sharedInstance] validateContactName:self.nameTextField.text];
        NSString *surname = [[BCTValidator sharedInstance] validateContactName:self.surnameTextField.text];
        NSString *mainPhone = self.phoneTextField.text;
        NSString *extraPhone = self.extraPhoneTextField.text;
        [[BCTDataBaseManager sharedInstance] createContactWithName:name
                                                           surname:surname
                                                   mainPhoneNumber:mainPhone
                                                  addedPhoneNumber:extraPhone
                                                         likedFlag:self.likedSwitch.on];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)validateFieldAndShowError {
    NSString *error = @"";
    if (self.nameTextField.text.length > 0) {
        if (![[BCTValidator sharedInstance] validateContactName:self.nameTextField.text]) {
            error = [error stringByAppendingString:@"Проверьте имя (от 1 до 15 символов)\n"];
        }
    } else {
        error = [error stringByAppendingString:@"Имя должно быть обязательно указано!\n"];
    }
    
    if (self.surnameTextField.text.length > 0) {
        if (![[BCTValidator sharedInstance] validatePhoneNumber:self.phoneTextField.text]) {
            error = [error stringByAppendingString:@"Неверный номер телефона\n"];
        }
    } else {
        error = [error stringByAppendingString:@"Номер телефона должен быть обязательно указан!\n"];
    }
    
    if (self.surnameTextField.text.length > 0 && ![[BCTValidator sharedInstance] validateContactSurname:self.surnameTextField.text]) {
        error = [error stringByAppendingString:@"Проверьте фамилию (от 3 до 20 символов)\n"];
    }
    
    if (self.extraPhoneTextField.text.length > 0 && ![[BCTValidator sharedInstance] validatePhoneNumber:self.extraPhoneTextField.text]) {
        error = [error stringByAppendingString:@"Неверный дополнительный номер телефона"];
    }
    
    if (error.length > 0) {
        [[AlertViewController sharedInstance] showErrorAlert:error animation:YES autoHide:YES];
    }
    return error.length > 0 ? NO : YES;
}

@end
