unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, Unix;

type

  { TForm1 }

  TForm1 = class(TForm)
    quit: TButton;
    apply: TButton;
    speedGroup: TGroupBox;
    senseGroup: TGroupBox;
    speedBar: TTrackBar;
    senseBar: TTrackBar;
    procedure applyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure quitClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

const
  conpath = '/etc/tmpfiles.d/tpconfig.conf';
  devpath1 = '/sys/devices/platform/i8042/serio1/serio2/';
  devpath2 = '/sys/devices/platform/i8042/serio1/';
  root = 'root';

var
  Form1: TForm1;
  confH: textfile;
  confile: string;
  tp: boolean;
  workingpath: string;
  sysfile: text;
  sensitivityt: string;
  speedt: string;
  sensitivity: byte;
  speed: byte;
  tempfile: text;
  user: string;
  messagereturn: longint;
  assembledStr: string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  fpsystem('touch '+conpath);
  tp := false;
  if FileExists(devpath1+'sensitivity') then
  begin
     tp := true;
     workingpath := devpath1;
  end;
  if FileExists(devpath2+'sensitivity') then
  begin
     tp := true;
     workingpath := devpath2;
  end;
  if not tp then
     begin
        messagereturn := Application.MessageBox('ERROR: No PS/2 TrackPoint!', 'Fatal Error');
        halt;
     end;
  if FileExists(conpath) then
  begin
     {AssignFile(confH, conpath);
     reset(confH);
     readln(confH, confile);
     debuglbl.Caption := filein;}
     AssignFile(sysfile, workingpath+'sensitivity');
     reset(sysfile);
     readln(sysfile, sensitivityt);
     {debuglbl.caption := sensitivityt;}
     val(sensitivityt, sensitivity);
     senseBar.Position := sensitivity;
     AssignFile(sysfile, workingpath+'speed');
     reset(sysfile);
     readln(sysfile, speedt);
     val(speedt, speed);
     speedBar.Position := speed;
     fpsystem('whoami >/tmp/tpconftmp');
     AssignFile(tempfile, '/tmp/tpconftmp');
     reset(tempfile);
     readln(tempfile, user);
     DeleteFile('/tmp/tpconftmp');
     if not (user=root) then
     begin
        messagereturn := Application.MessageBox('ERROR: Not root!', 'Fatal Error');
        halt;

     end;
  end;
end;

procedure TForm1.applyClick(Sender: TObject);
begin
  sensitivity := senseBar.Position;
  speed := speedBar.Position;
  AssignFile(confH, conpath);
  rewrite(confH);
  assembledStr := 'w '+workingpath+'sensitivity - - - - '+IntToStr(sensitivity);
  {debuglbl.Caption := assembledStr;}
  writeln(confH, assembledStr);
  assembledStr := 'w '+workingpath+'speed - - - - '+IntToStr(speed);
  writeln(confH, assembledStr);
  CloseFile(confH);
  {messagereturn := Application.MessageBox('sysd file written', 'Debugger');}
  fpsystem('systemd-tmpfiles --prefix=/sys --create');
end;

procedure TForm1.quitClick(Sender: TObject);
begin
  {$I-}
  halt;
end;


end.

