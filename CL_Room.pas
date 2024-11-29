unit CL_Room;

interface

  uses
    // Windows Units
    // Delphi Units
    FMX.Controls,
    FMX.Controls.Presentation,
    FMX.Dialogs,
    FMX.Forms,
    FMX.Graphics,
    FMX.Layouts,
    FMX.Objects,
    FMX.StdCtrls,
    FMX.Types,
    System.Classes,
    System.SysUtils,
    System.Types,
    System.UITypes,
    System.Variants,
    // SIVille Units
    CL_Grid;

  type

    tchar = record
      X : integer;
      Y : integer;
    end;

    TClassRoom = class( TForm )
      Bttn_ly : TLayout;
      Button1 : TButton;
      plyScr_Ly : TLayout;
      Rectangle1 : TRectangle;
      Rectangle2 : TRectangle;
      Rectangle3 : TRectangle;
      Rectangle4 : TRectangle;
      procedure Button1Click( Sender : TObject );
      procedure FormActivate( Sender : TObject );
      procedure FormCreate( Sender : TObject );
      procedure Rectangle1Click( Sender : TObject );
      procedure Rectangle2Click( Sender : TObject );
      procedure Rectangle3Click( Sender : TObject );
      procedure Rectangle4Click( Sender : TObject );
      private
        procedure ShowCharacter;
        procedure ShowGameGrid;
      public
        { Public declarations }
        GameGrid    : TGameGrid;
        MyCharacter : tchar;
    end;

  var
    ClassRoom : TClassRoom;

implementation

  {$r *.fmx}

  uses
    // SIVille Units
    uMain;

  procedure TClassRoom.Button1Click( Sender : TObject );
    begin
      application.Terminate;
    end;

  procedure TClassRoom.FormActivate( Sender : TObject );
    begin
      if Assigned( GameGrid )
      then
        begin
          FreeAndNil( GameGrid ); // Destroy existing grid if already created
        end;

      GameGrid        := TGameGrid.Create( plyScr_Ly, 18, 24, 30 );
      Button1.Visible := True;
      Button1.BringToFront;

      Bttn_ly.BringToFront;

      Button1.Position.X := 1480;
      Button1.Position.Y := 0;

      ShowGameGrid;
      // create di imo character bosss tas mga Object na need mo for this room ging sudlan
    end;

  procedure TClassRoom.FormCreate( Sender : TObject );
    begin
      MyCharacter.X := 12;
      MyCharacter.Y := 16;
    end;

  procedure TClassRoom.Rectangle1Click( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X - 1, MyCharacter.Y ) <> 'Wall'
      then
        begin
          MyCharacter.X := MyCharacter.X - 1;
        end;
    end;

  procedure TClassRoom.Rectangle2Click( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X, MyCharacter.Y - 1 ) <> 'Wall'
      then
        begin
          MyCharacter.Y := MyCharacter.Y - 1;
        end;
    end;

  procedure TClassRoom.Rectangle3Click( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X + 1, MyCharacter.Y ) <> 'Wall'
      then
        begin
          MyCharacter.X := MyCharacter.X + 1;
        end;
    end;

  procedure TClassRoom.Rectangle4Click( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X, MyCharacter.Y + 1 ) <> 'Wall'
      then
        begin
          MyCharacter.Y := MyCharacter.Y + 1;
        end;
    end;

  procedure TClassRoom.ShowCharacter;
    begin
      GameGrid.UpdateTileType( MyCharacter.X, MyCharacter.Y, 'Character' );
    end;

  procedure TClassRoom.ShowGameGrid;
    begin
      if IsGameOver
      then
        begin
          Exit;
        end;

      if Assigned( GameGrid )
      then
        begin
          with GameGrid do
            begin
              // door position  Rows, Columns,
              UpdateTileType( 11, 16, 'Door' );
              UpdateTileType( 12, 16, 'Door' );
              UpdateTileType( 13, 16, 'Door' );

              // teacher Position
              UpdateTileType( 12, 2, 'Teacher' );

              // Table 1 Position
              UpdateTileType( 4, 7, 'Table' );
              UpdateTileType( 5, 7, 'Table' );
              UpdateTileType( 6, 7, 'Table' );
              UpdateTileType( 7, 7, 'Table' );
              UpdateTileType( 8, 7, 'Table' );

              // table 2 position
              UpdateTileType( 10, 7, 'Table' );
              UpdateTileType( 11, 7, 'Table' );
              UpdateTileType( 12, 7, 'Table' );
              UpdateTileType( 13, 7, 'Table' );
              UpdateTileType( 14, 7, 'Table' );

              // table 3 position
              UpdateTileType( 16, 7, 'Table' );
              UpdateTileType( 17, 7, 'Table' );
              UpdateTileType( 18, 7, 'Table' );
              UpdateTileType( 19, 7, 'Table' );
              UpdateTileType( 20, 7, 'Table' );

              // table 4 position
              UpdateTileType( 4, 9, 'Table' );
              UpdateTileType( 5, 9, 'Table' );
              UpdateTileType( 6, 9, 'Table' );
              UpdateTileType( 7, 9, 'Table' );
              UpdateTileType( 8, 9, 'Table' );

              // table 5 position
              UpdateTileType( 10, 9, 'Table' );
              UpdateTileType( 11, 9, 'Table' );
              UpdateTileType( 12, 9, 'Table' );
              UpdateTileType( 13, 9, 'Table' );
              UpdateTileType( 14, 9, 'Table' );

              // table 6 position
              UpdateTileType( 16, 9, 'Table' );
              UpdateTileType( 17, 9, 'Table' );
              UpdateTileType( 18, 9, 'Table' );
              UpdateTileType( 19, 9, 'Table' );
              UpdateTileType( 20, 9, 'Table' );

              // table 7 position
              UpdateTileType( 4, 11, 'Table' );
              UpdateTileType( 5, 11, 'Table' );
              UpdateTileType( 6, 11, 'Table' );
              UpdateTileType( 7, 11, 'Table' );
              UpdateTileType( 8, 11, 'Table' );

              // table 8 position
              UpdateTileType( 10, 11, 'Table' );
              UpdateTileType( 11, 11, 'Table' );
              UpdateTileType( 12, 11, 'Table' );
              UpdateTileType( 13, 11, 'Table' );
              UpdateTileType( 14, 11, 'Table' );

              // table 9 position
              UpdateTileType( 16, 11, 'Table' );
              UpdateTileType( 17, 11, 'Table' );
              UpdateTileType( 18, 11, 'Table' );
              UpdateTileType( 19, 11, 'Table' );
              UpdateTileType( 20, 11, 'Table' );

              UpdateTileType( 12, 2, 'Teacher' );
            end;
        end;
    end;

end.
