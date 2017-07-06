page 1805 "Email Setup Wizard"
{
  // version NAVW110.00

  CaptionML=ENU='Email Setup';
  PageType=NavigatePage;
  SourceTable="SMTP Mail Setup";
  SourceTableTemporary=true;

  layout
  {
    area(content)
    {
      group(Group96)
      {
        Editable=false;
        Visible=TopBannerVisible AND NOT FinalStepVisible;
        field(MediaResourcesStandard;MediaResourcesStandard."Media Reference")
        {
          ApplicationArea=Basic,Suite,Invoicing;
          Editable=false;
          ShowCaption=false;
        }
      }
      group(Group98)
      {
        Editable=false;
        Visible=TopBannerVisible AND FinalStepVisible;
        field(MediaResourcesDone;MediaResourcesDone."Media Reference")
        {
          ApplicationArea=Basic,Suite,Invoicing;
          Editable=false;
          ShowCaption=false;
        }
      }
      group("<MediaRepositoryDone>")
      {
        Visible=FirstStepVisible;
        group("Welcome to Email Setup")
        {
          CaptionML=ENU='Welcome to Email Setup';
          Visible=FirstStepVisible;
          group(Group18)
          {
            InstructionalTextML=ENU='To send email messages using actions on documents, such as the Sales Invoice window, you must log on to the relevant email account.';
          }
        }
        group("Let's go!")
        {
          CaptionML=ENU='Let''s go!';
          group(Group22)
          {
            InstructionalTextML=ENU='Choose Next so you can set up email sending from documents.';
          }
        }
      }
      group(Group2)
      {
        InstructionalTextML=ENU='Choose your email provider.';
        Visible=ProviderStepVisible;
        field("Email Provider";EmailProvider)
        {
          ApplicationArea=Basic,Suite,Invoicing;
          CaptionML=ENU='Email Provider';

          trigger OnValidate();
          begin
            IF EmailProvider = EmailProvider::"Office 365" THEN
              SMTPMail.ApplyOffice365Smtp(Rec)
            ELSE
              "SMTP Server" := '';
            EnableControls;
          end;
        }
      }
      group(Group12)
      {
        Visible=SettingsStepVisible;
        group(Group27)
        {
          InstructionalTextML=ENU='Enter the SMTP Server Details.';
          Visible=AdvancedSettingsVisible;
          field(Authentication;Authentication)
          {
            ApplicationArea=Basic,Suite,Invoicing;

            trigger OnValidate();
            begin
              EnableControls;
            end;
          }
          field("SMTP Server";"SMTP Server")
          {
            ApplicationArea=Basic,Suite,Invoicing;
            ShowMandatory=true;

            trigger OnValidate();
            begin
              EnableControls;
            end;
          }
          field("SMTP Server Port";"SMTP Server Port")
          {
            ApplicationArea=Basic,Suite,Invoicing;
          }
          field("Secure Connection";"Secure Connection")
          {
            ApplicationArea=Basic,Suite,Invoicing;
          }
        }
        group(Group26)
        {
          InstructionalTextML=ENU='Enter the credentials for the account, which will be used for sending emails.';
          Visible=MailSettingsVisible;
          field(Email;"User ID")
          {
            ApplicationArea=Basic,Suite,Invoicing;
            ExtendedDatatype=EMail;

            trigger OnValidate();
            begin
              EnableControls;
            end;
          }
          field(Password;Password)
          {
            ApplicationArea=Basic,Suite,Invoicing;
            CaptionML=ENU='Password';
            ExtendedDatatype=Masked;

            trigger OnValidate();
            begin
              EnableControls;
            end;
          }
        }
      }
      group(Group17)
      {
        Visible=FinalStepVisible;
        group(Group23)
        {
          InstructionalTextML=ENU='To verify that the specified email setup works, choose Send Test Email.';
        }
        group("That's it!")
        {
          CaptionML=ENU='That''s it!';
          group(Group25)
          {
            InstructionalTextML=ENU='To enable email sending directly from documents, choose Finish.';
          }
        }
      }
    }
  }

  actions
  {
    area(processing)
    {
      action(ActionBack)
      {
        ApplicationArea=Basic,Suite,Invoicing;
        CaptionML=ENU='Back';
        Enabled=BackActionEnabled;
        Image=PreviousRecord;
        InFooterBar=true;

        trigger OnAction();
        begin
          NextStep(TRUE);
        end;
      }
      action(ActionNext)
      {
        ApplicationArea=Basic,Suite,Invoicing;
        CaptionML=ENU='Next';
        Enabled=NextActionEnabled;
        Image=NextRecord;
        InFooterBar=true;

        trigger OnAction();
        begin
          CASE Step OF
            Step::Settings:
              IF (Authentication = Authentication::Basic) AND (("User ID" = '') OR (Password = '')) THEN
                ERROR(EmailPasswordMissingErr);
          END;

          NextStep(FALSE);
        end;
      }
      action(ActionSendTestEmail)
      {
        ApplicationArea=Basic,Suite,Invoicing;
        CaptionML=ENU='Send Test Email';
        Enabled=true;
        Image=Email;
        InFooterBar=true;
        Visible=FinishActionEnabled;

        trigger OnAction();
        begin
          SendTestEmailAction;
        end;
      }
      action(ActionFinish)
      {
        ApplicationArea=Basic,Suite,Invoicing;
        CaptionML=ENU='Finish';
        Enabled=FinishActionEnabled;
        Image=Approve;
        InFooterBar=true;

        trigger OnAction();
        begin
          FinishAction;
        end;
      }
    }
  }

  trigger OnInit();
  begin
    LoadTopBanners;
  end;

  trigger OnOpenPage();
  var
    SMTPMailSetup : Record 409;
    CompanyInformation : Record 79;
    SMTPMail : Codeunit 400;
  begin
    INIT;
    IF SMTPMailSetup.GET THEN BEGIN
      TRANSFERFIELDS(SMTPMailSetup);
      IF SMTPMail.IsOffice365Setup(SMTPMailSetup) THEN
        EmailProvider := EmailProvider::"Office 365"
      ELSE
        EmailProvider := EmailProvider::Other;
    END ELSE BEGIN
      SMTPMail.ApplyOffice365Smtp(Rec);
      EmailProvider := EmailProvider::"Office 365";
      IF CompanyInformation.GET THEN
        "User ID" := CompanyInformation."E-Mail";
    END;
    INSERT;
    IF SMTPMailSetup.HasPassword THEN
      Password := DummyPasswordTxt;

    Step := Step::Start;
    EnableControls;
  end;

  trigger OnQueryClosePage(CloseAction : Action) : Boolean;
  begin
    IF CloseAction = ACTION::OK THEN
      IF AssistedSetup.GetStatus(PAGE::"Email Setup Wizard") = AssistedSetup.Status::"Not Completed" THEN
        IF NOT CONFIRM(NAVNotSetUpQst,FALSE) THEN
          ERROR('');
  end;

  var
    AssistedSetup : Record 1803;
    MediaRepositoryStandard : Record 9400;
    MediaRepositoryDone : Record 9400;
    MediaResourcesStandard : Record 2000000182;
    MediaResourcesDone : Record 2000000182;
    SMTPMail : Codeunit 400;
    Step : Option Start,Provider,Settings,Finish;
    TopBannerVisible : Boolean;
    FirstStepVisible : Boolean;
    ProviderStepVisible : Boolean;
    SettingsStepVisible : Boolean;
    AdvancedSettingsVisible : Boolean;
    MailSettingsVisible : Boolean;
    FinalStepVisible : Boolean;
    EmailProvider : Option "Office 365",Other;
    FinishActionEnabled : Boolean;
    BackActionEnabled : Boolean;
    NextActionEnabled : Boolean;
    NAVNotSetUpQst : TextConst ENU='Email has not been set up.\\Are you sure you want to exit?';
    EmailPasswordMissingErr : TextConst ENU='Please enter a valid email address and password.';
    Password : Text[250];
    DummyPasswordTxt : TextConst Comment='{Locked}',ENU='***';

  local procedure EnableControls();
  begin
    ResetControls;

    CASE Step OF
      Step::Start:
        ShowStartStep;
      Step::Provider:
        ShowProviderStep;
      Step::Settings:
        ShowSettingsStep;
      Step::Finish:
        ShowFinishStep;
    END;
  end;

  local procedure StoreSMTPSetup();
  var
    SMTPMailSetup : Record 409;
  begin
    IF NOT SMTPMailSetup.GET THEN BEGIN
      SMTPMailSetup.INIT;
      SMTPMailSetup.INSERT;
    END;

    SMTPMailSetup.TRANSFERFIELDS(Rec,FALSE);
    IF Password <> DummyPasswordTxt THEN
      SMTPMailSetup.SetPassword(Password);
    SMTPMailSetup.MODIFY(TRUE);
    COMMIT;
  end;

  local procedure SendTestEmailAction();
  begin
    StoreSMTPSetup;
    CODEUNIT.RUN(CODEUNIT::"SMTP Test Mail");
  end;

  local procedure FinishAction();
  begin
    StoreSMTPSetup;
    AssistedSetup.SetStatus(PAGE::"Email Setup Wizard",AssistedSetup.Status::Completed);
    CurrPage.CLOSE;
  end;

  local procedure NextStep(Backwards : Boolean);
  begin
    IF Backwards THEN
      Step := Step - 1
    ELSE
      Step := Step + 1;

    EnableControls;
  end;

  local procedure ShowStartStep();
  begin
    FirstStepVisible := TRUE;
    FinishActionEnabled := FALSE;
    BackActionEnabled := FALSE;
  end;

  local procedure ShowProviderStep();
  begin
    ProviderStepVisible := TRUE;
  end;

  local procedure ShowSettingsStep();
  begin
    SettingsStepVisible := TRUE;
    AdvancedSettingsVisible := EmailProvider = EmailProvider::Other;
    MailSettingsVisible := Authentication = Authentication::Basic;
    NextActionEnabled := "SMTP Server" <> '';
  end;

  local procedure ShowFinishStep();
  begin
    FinalStepVisible := TRUE;
    NextActionEnabled := FALSE;
    FinishActionEnabled := TRUE;
  end;

  local procedure ResetControls();
  begin
    FinishActionEnabled := FALSE;
    BackActionEnabled := TRUE;
    NextActionEnabled := TRUE;

    FirstStepVisible := FALSE;
    ProviderStepVisible := FALSE;
    SettingsStepVisible := FALSE;
    FinalStepVisible := FALSE;
  end;

  local procedure LoadTopBanners();
  begin
    IF MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png',FORMAT(CURRENTCLIENTTYPE)) AND
       MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png',FORMAT(CURRENTCLIENTTYPE))
    THEN
      IF MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") AND
         MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
      THEN
        TopBannerVisible := MediaResourcesDone."Media Reference".HASVALUE;
  end;
}

