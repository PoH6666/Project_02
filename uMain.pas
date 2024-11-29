unit uMain;

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
    Pathfinding,
    System.Classes,
    System.Generics.Collections, // Include the unit for TGameGrid
    System.SysUtils,
    System.Types,
    System.UITypes,
    System.Variants,
    // SIVille Units
    uGameGrid;

  type

    tchar = record
      X : integer;
      Y : integer;
    end;

    TfrmMain = class( TForm )
      character : TBrushObject;
      Door : TBrushObject;
      Grass : TBrushObject;
      Label1 : TLabel;
      Label2 : TLabel;
      Label3 : TLabel;
      Label4 : TLabel;
      lblFindPath : TLabel;
      lyBottom : TLayout;
      lyButtons : TLayout;
      lyRoom : TLayout;
      recDown : TRectangle;
      recLeft : TRectangle;
      recQuit : TRectangle;
      recRight : TRectangle;
      recRoom_1 : TRectangle;
      Rectangle1 : TRectangle;
      Rectangle2 : TRectangle;
      Rectangle7 : TRectangle;
      Rectangle8 : TRectangle;
      recUP : TRectangle;
      Room : TBrushObject;
      Timer1 : TTimer;
      wall : TBrushObject;
      water : TBrushObject;
      procedure FormCreate( Sender : TObject );
      procedure lblFindPathClick( Sender : TObject );
      procedure lyPlayScreenClick( Sender : TObject );
      procedure recDownClick( Sender : TObject );
      procedure recLeftClick( Sender : TObject );
      procedure recQuitClick( Sender : TObject );
      procedure recRightClick( Sender : TObject );
      procedure Rectangle1Click( Sender : TObject );
      procedure Rectangle8Click( Sender : TObject );
      procedure recUPClick( Sender : TObject );
      private
        procedure CreateGameGrid;
        procedure ShowCharacter;
        procedure ShowGameGrid;
        procedure ShowPathFound( lPath : tList< TPoint > );
        procedure ShowRoom;
      public
        GameGrid        : TGameGrid; // Declare the TGameGrid object
        IsClassRoomOpen : Boolean;
        MyCharacter     : tchar;
        Pathfinding     : TPathfinding;
        procedure CheckCollision;
        procedure MoveCharacterTo( TargetX, TargetY : integer );
    end;

  var
    frmMain  : TfrmMain;
    gameover : Boolean;

implementation

  {$r *.fmx}

  uses
    // SIVille Units
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

  procedure TfrmMain.CreateGameGrid;
    begin
      if Assigned( GameGrid )
      then
        begin
          FreeAndNil( GameGrid ); // Destroy existing grid if already created
        end;

      GameGrid           := TGameGrid.Create( lyRoom, 18, 36, 30 ); // 10 rows, 10 columns, tile size of 50x50
      Rectangle7.Visible := false;
      gameover           := false;
    end;

  procedure TfrmMain.FormCreate( Sender : TObject );
    begin
      gameover      := True;
      MyCharacter.X := 16;
      MyCharacter.Y := 15;

      recRoom_1.Visible := false;

      if Assigned( GameGrid )
      then
        begin
          Pathfinding := TPathfinding.Create( GameGrid, 36, 18 ); // Columns, Rows
        end;
    end;

  procedure TfrmMain.lblFindPathClick( Sender : TObject );
    var
      TargetX    : integer;
      TargetY    : integer;
      ClickPoint : TPointF;
      lResult    : tList< TPoint >;
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

  procedure TfrmMain.lyPlayScreenClick( Sender : TObject );
    var
      TargetX    : integer;
      TargetY    : integer;
      ClickPoint : TPointF;
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
        begin
          Exit;
        end;

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

  procedure TfrmMain.recDownClick( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X, MyCharacter.Y + 1 ) <> 'Wall'
      then
        begin
          MyCharacter.Y := MyCharacter.Y + 1;
        end;
    end;

  procedure TfrmMain.recLeftClick( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X - 1, MyCharacter.Y ) <> 'Wall'
      then
        begin
          MyCharacter.X := MyCharacter.X - 1;
        end;
    end;

  procedure TfrmMain.recQuitClick( Sender : TObject );
    begin
      gameover := True;
    end;

  procedure TfrmMain.recRightClick( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X + 1, MyCharacter.Y ) <> 'Wall'
      then
        begin
          MyCharacter.X := MyCharacter.X + 1;
        end;
    end;

  procedure TfrmMain.Rectangle1Click( Sender : TObject );
    begin
      CreateGameGrid;
      ShowRoom;
      ShowGameGrid;
      ShowCharacter;
    end;

  procedure TfrmMain.Rectangle8Click( Sender : TObject );
    begin
      ClassRoom.Show;
    end;

  procedure TfrmMain.recUPClick( Sender : TObject );
    begin
      if GameGrid.GetTileType( MyCharacter.X, MyCharacter.Y - 1 ) <> 'Wall'
      then
        begin
          MyCharacter.Y := MyCharacter.Y - 1;
        end;

      CheckCollision; // Check collision after moving up
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

  procedure TfrmMain.ShowPathFound( lPath : tList< TPoint > );
    var
      i : integer;
      p : TPoint;
    begin
      p     := TPoint.Create( 0, 0 );
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

end.
