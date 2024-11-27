program SIVilleProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmMain},
  uGameGrid in 'uGameGrid.pas',
  CL_Room in 'CL_Room.pas' {ClassRoom},
  CL_Grid in 'CL_Grid.pas',
  Pathfinding in 'Pathfinding.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
