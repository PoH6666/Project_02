unit uMain;

interface

  uses
    System.SysUtils,
    System.Types,
    System.UITypes,
    System.Classes,
    System.Variants,
    FMX.Types,
    FMX.Controls,
    FMX.Forms,
    FMX.Graphics,
    FMX.Dialogs,
    uGameGrid,
    Pathfinding,
    FMX.Objects,
    FMX.Layouts,
    FMX.Controls.Presentation,
    FMX.StdCtrls,
    System.Generics.Collections; // Include the unit for TGameGrid

  type

    tchar = record
      X, Y : integer;
    end;

    TfrmMain = class( TForm )
      Rectangle1 : TRectangle;
      lyRoom : TLayout;
      recQuit : TRectangle;
      Timer1 : TTimer;
      recUP : TRectangle;
      recDown : TRectangle;
      lyButtons : TLayout;
      recRight : TRectangle;
      recLeft : TRectangle;
      character : TBrushObject;
      Door : TBrushObject;
      Grass : TBrushObject;
      Room : TBrushObject;
      wall : TBrushObject;
      water : TBrushObject;
      Rectangle7 : TRectangle;
      Rectangle8 : TRectangle;
      lyBottom : TLayout;
      Label1 : TLabel;
      Label2 : TLabel;
      Label4 : TLabel;
      Label3 : TLabel;
      Rectangle2 : TRectangle;
      lblFindPath : TLabel;
      recRoom_1 : TRectangle;
      procedure FormCreate( Sender : TObject );
      procedure Rectangle1Click( Sender : TObject );
      procedure recQuitClick( Sender : TObject );
      procedure recUPClick( Sender : TObject );
      procedure recDownClick( Sender : TObject );
      procedure recRightClick( Sender : TObject );
      procedure recLeftClick( Sender : TObject );
      procedure Rectangle8Click( Sender : TObject );
      procedure lyPlayScreenClick( Sender : TObject );
      procedure lblFindPathClick( Sender : TObject );

      private
        procedure CreateGameGrid;
        procedure ShowRoom;
        procedure ShowGameGrid;
        procedure ShowCharacter;
        procedure ShowPathFound( lPath : tList< TPoint > );
        { Private declarations }

      public
        { Public declarations }
        GameGrid        : TGameGrid; // Declare the TGameGrid object
        Pathfinding     : TPathfinding;
        MyCharacter     : tchar;
        IsClassRoomOpen : Boolean;
        procedure CheckCollision;
        procedure MoveCharacterTo( TargetX, TargetY : integer );
    end;

  var
    frmMain  : TfrmMain;
    gameover : Boolean;

implementation

  {$r *.fmx}

  uses
    CL_Room;

  procedure TfrmMain.CheckCollision;
    var
      DoorPositions : array of TPoint; // Define an array to hold door positions
      i             : integer;
    begin
      // Define door positions
      SetLength( DoorPositions, 3 ); // Adjust the size based on the number of doors
      DoorPositions[ 0 ] := TPoint.Create( 6, 5 ); // Classroom door
      DoorPositions[ 1 ] := TPoint.Create( 6, 4 ); // Another door (if needed)
      DoorPositions[ 2 ] := TPoint.Create( 29, 3 ); // Yet another door

      // Check if MyCharacter is at any of the door positions
      for i := 0 to high( DoorPositions ) do
        begin
          if ( MyCharacter.X = DoorPositions[ i ].X ) and ( MyCharacter.Y = DoorPositions[ i ].Y )
          then
            begin
              if not IsClassRoomOpen
              then
                begin
                  if not Assigned( ClassRoom )
                  then
                    ClassRoom := TClassRoom.Create( Application ); // Create if not already created

                  ClassRoom.Show;
                  IsClassRoomOpen := True; // Prevent reopening until explicitly reset
                end;
              Break; // Exit loop after opening the Classroom
            end;
        end;
    end;

  procedure TfrmMain.FormCreate( Sender : TObject );
    begin
      gameover      := True;
      MyCharacter.X := 16;
      MyCharacter.Y := 15;

      recRoom_1.Visible := false;

      if Assigned( GameGrid )
      then
        Pathfinding := TPathfinding.Create( GameGrid, 36, 18 ); // Columns, Rows
    end;

  procedure TfrmMain.lblFindPathClick( Sender : TObject );
    var
      TargetX, TargetY : integer;
      ClickPoint       : TPointF;

      lResult : tList< TPoint >;

    begin

      // Door n 1 room n 1
      TargetX := 6;
      TargetY := 5;

      // starting point
      // MyCharacter X
      // MyCharacter  Y

      with TPathfinding.Create( GameGrid, GameGrid.Rows, GameGrid.Cols ) do
        try
          lResult := FindPath( MyCharacter.X, MyCharacter.Y, TargetX, TargetY );

          if Assigned( lResult )
          then
            begin
              ShowPathFound( lResult );
            end;

        finally
          free;
        end;
    end;

  procedure TfrmMain.ShowPathFound( lPath : tList< TPoint > );
    var
      i : integer;
      p : TPoint;
    begin

      p := TPoint.Create( 0, 0 );

      for i := 0 to lPath.Count - 1 do
        begin
          p.X := lPath[ i ].X;
          p.Y := lPath[ i ].Y;
          // Update character position
          MyCharacter.X := p.X;
          MyCharacter.Y := p.Y;

          // Update the grid
          GameGrid.UpdateTileType( MyCharacter.X, MyCharacter.Y, 'Character' );
          Sleep( 100 ); // Optional delay for smooth animation
          Application.ProcessMessages; // Ensure UI updates in real-time

        end;
    end;

  procedure TfrmMain.lyPlayScreenClick( Sender : TObject );
    var
      TargetX, TargetY : integer;
      ClickPoint       : TPointF;
    begin
      showmessage( 'Enter play screen' );
      // Get the click position relative to lyRoom
      if Sender is TControl
      then
        begin
          // Convert the screen click position to lyRoom's local coordinates
          ClickPoint := lyRoom.AbsoluteToLocal( Screen.MousePos );

          // Optional: Convert to grid coordinates if you're using a tile-based grid
          TargetX := Round( ClickPoint.X );
          TargetY := Round( ClickPoint.Y );

          // Move the character to the clicked position
          MoveCharacterTo( TargetX, TargetY );
        end;
    end;

  procedure TfrmMain.MoveCharacterTo( TargetX, TargetY : integer );
    var
      Path  : tList< TPoint >;
      Point : TPoint;
    begin
      if not Assigned( Pathfinding )
      then
        Exit;

      Path := Pathfinding.FindPath( MyCharacter.X, MyCharacter.Y, TargetX, TargetY );
      try
        for Point in Path do
          begin
            // Update character position
            MyCharacter.X := Point.X;
            MyCharacter.Y := Point.Y;

            // Update the grid
            GameGrid.UpdateTileType( MyCharacter.X, MyCharacter.Y, 'Character' );
            Sleep( 100 ); // Optional delay for smooth animation
            Application.ProcessMessages; // Ensure UI updates in real-time
          end;
      finally
        Path.free;
      end;
    end;

  procedure TfrmMain.ShowRoom;
    begin
      recRoom_1.Visible := false;
      // Create a new rectangle to display in front of the grid
      recRoom_1.Width      := 225; // Set width of rectangle
      recRoom_1.Height     := 245; // Set height of rectangle
      recRoom_1.Position.X := 88; // Set X position (adjust as needed)
      recRoom_1.Position.Y := 110; // Set Y position (adjust as needed)
      recRoom_1.BringToFront; // Bring rectangle to the front of all other controls
    end;

  procedure TfrmMain.CreateGameGrid;
    begin
      if Assigned( GameGrid )
      then
        FreeAndNil( GameGrid ); // Destroy existing grid if already created

      GameGrid           := TGameGrid.Create( lyRoom, 18, 36, 30 ); // 10 rows, 10 columns, tile size of 50x50
      Rectangle7.Visible := false;
      gameover           := false;
    end;

  procedure TfrmMain.ShowCharacter;
    begin
      Label1.Text := 'X = ' + IntToStr( MyCharacter.X );
      Label2.Text := 'Y = ' + IntToStr( MyCharacter.Y );
      GameGrid.UpdateTileType( MyCharacter.X, MyCharacter.Y, 'Character' ); // Bottom-right corner
      CheckCollision;
    end;

  procedure TfrmMain.ShowGameGrid;
    begin
      if not gameover
      then
        begin
          // Place walls in the four corners
          if Assigned( GameGrid )
          then
            begin
              with GameGrid do
                begin
                  UpdateTileType( 6, 4, 'Door' );
                  UpdateTileType( 6, 5, 'Door' );
                  UpdateTileType( 2, 2, 'Wall' );
                  UpdateTileType( 2, 3, 'Wall' );
                  UpdateTileType( 2, 4, 'Wall' );
                  UpdateTileType( 2, 5, 'Wall' );
                  UpdateTileType( 2, 6, 'Wall' );
                  UpdateTileType( 5, 4, 'Wall' );
                  UpdateTileType( 5, 5, 'Wall' );
                  UpdateTileType( 3, 2, 'Wall' );
                  UpdateTileType( 3, 6, 'Wall' );
                  UpdateTileType( 4, 6, 'Wall' );
                  UpdateTileType( 5, 6, 'Wall' );
                  UpdateTileType( 4, 2, 'Wall' );
                  UpdateTileType( 5, 2, 'Wall' );
                  UpdateTileType( 6, 2, 'Wall' );
                  UpdateTileType( 6, 3, 'Wall' );
                  UpdateTileType( 6, 6, 'Wall' );
                  UpdateTileType( 32, 1, 'Room' ); // Top-right corner
                  UpdateTileType( 31, 1, 'Room' );
                  UpdateTileType( 30, 1, 'Room' );
                  UpdateTileType( 29, 1, 'Room' );
                  UpdateTileType( 32, 2, 'Room' );
                  UpdateTileType( 31, 2, 'Room' );
                  UpdateTileType( 30, 2, 'Room' );
                  UpdateTileType( 29, 2, 'Room' );
                  UpdateTileType( 15, 9, 'Wall' );
                  UpdateTileType( 16, 9, 'Wall' );
                  UpdateTileType( 17, 9, 'Wall' );
                  UpdateTileType( 32, 3, 'Room' );
                  UpdateTileType( 31, 3, 'Room' );
                  UpdateTileType( 30, 3, 'Room' );
                  UpdateTileType( 29, 3, 'Door' );
                  UpdateTileType( 32, 4, 'Room' );
                  UpdateTileType( 31, 4, 'Room' );
                  UpdateTileType( 30, 4, 'Room' );
                  UpdateTileType( 29, 4, 'Room' );
                  UpdateTileType( 32, 5, 'Room' );
                  UpdateTileType( 31, 5, 'Room' );
                  UpdateTileType( 30, 5, 'Room' );
                  UpdateTileType( 29, 5, 'Room' );
                  UpdateTileType( 13, 14, 'Wall' );
                  UpdateTileType( 15, 14, 'Wall' );
                  UpdateTileType( 12, 14, 'Wall' );
                end;
            end;
        end;
    end;

  procedure TfrmMain.Rectangle1Click( Sender : TObject );
    begin
      CreateGameGrid;
      ShowRoom;
      ShowGameGrid;
      ShowCharacter;
    end;

  procedure TfrmMain.recQuitClick( Sender : TObject );
    begin
      gameover := True;
    end;

  procedure TfrmMain.recUPClick( Sender : TObject );
    begin

      if GameGrid.GetTileType( MyCharacter.X, MyCharacter.Y - 1 ) <> 'Wall'
      then
        MyCharacter.Y := MyCharacter.Y - 1;
      CheckCollision; // Check collision after moving up

    end;

  procedure TfrmMain.recDownClick( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X, MyCharacter.Y + 1 ) <> 'Wall'
      then
        MyCharacter.Y := MyCharacter.Y + 1;
    end;

  procedure TfrmMain.recRightClick( Sender : TObject );
    begin

      if GameGrid.GetTileType( MyCharacter.X + 1, MyCharacter.Y ) <> 'Wall'
      then
        MyCharacter.X := MyCharacter.X + 1;
    end;

  procedure TfrmMain.recLeftClick( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X - 1, MyCharacter.Y ) <> 'Wall'
      then
        MyCharacter.X := MyCharacter.X - 1;
    end;

  procedure TfrmMain.Rectangle8Click( Sender : TObject );
    begin
      ClassRoom.Show;
    end;

end.
