unit uGameGrid;

interface

  uses
    // Windows Units
    // Delphi Units
    FMX.Controls,
    FMX.Graphics,
    FMX.Objects,
    FMX.Types,
    System.Classes,
    System.Generics.Collections,
    System.SysUtils,
    System.Types,
    System.UITypes;

  type
    // A single grid tile, representing an element in the map
    TGridTile = class
      private
        FTileRect : TRectangle; // Visual representation of the tile
        FTileType : string; // Type of the tile (e.g., 'Grass', 'Water', 'Wall')
      public
        constructor Create( ATileType : string; APosition : TPointF; ASize : Single );
        property TileRect : TRectangle read FTileRect;
        property TileType : string read FTileType write FTileType;
    end;

    // The grid, consisting of multiple tiles
    TGameGrid = class( TObject )
      private
        FCols          : Integer; // Number of columns in the grid
        FGridTiles     : TObjectList< TGridTile >; // List of all grid tiles
        FParentControl : TControl; // Parent control to hold the grid (e.g., Form or a Panel)
        FRows          : Integer; // Number of rows in the grid
        FTileSize      : Single; // Size of each tile
      public
        constructor Create( AParent : TControl; ARows, ACols : Integer; ATileSize : Single );
        destructor Destroy; override;
        procedure CreateGrid;
        function GetTileType( X, Y : Integer ) : string;
        procedure RenderGrid; // Render the grid on the parent control
        procedure UpdateTileType( X, Y : Integer; ATileType : string ); // Update tile type at a specific grid position
        property Cols : Integer read FCols;
        property Rows : Integer read FRows;
    end;

implementation

  { TGridTile }

  constructor TGridTile.Create( ATileType : string; APosition : TPointF; ASize : Single );
    begin
      FTileType := ATileType;

      // Create visual representation of the tile
      FTileRect                := TRectangle.Create( nil );
      FTileRect.Width          := ASize;
      FTileRect.Height         := ASize;
      FTileRect.Position.Point := APosition;
      FTileRect.Stroke.Kind    := TBrushKind.None;

      FTileRect.Fill.Kind := TBrushKind.Solid; // Set to Bitmap by default

      // Load images or colors based on tile type
      if ATileType = 'Grass'
      then
        begin
          FTileRect.Fill.Color := TAlphaColors.Green;
        end
      else if ATileType = 'Wall'
      then
        begin
          FTileRect.Fill.Color := TAlphaColors.Black;
        end
      else if ATileType = 'Ground'
      then
        begin
          FTileRect.Fill.Color := TAlphaColors.Tan;
        end
      else if ATileType = 'Room'
      then
        begin
          FTileRect.Fill.Color := TAlphaColors.Red;
        end
      else if ATileType = 'Door'
      then
        begin
          FTileRect.Fill.Color := TAlphaColors.Blue;
        end
      else if ATileType = 'Character'
      then
        begin
          FTileRect.Fill.Color := TAlphaColors.Yellow;
        end
      else
        begin
          FTileRect.Fill.Color := TAlphaColors.White; // Default color for unclassified tiles
        end;
    end;

  { TGameGrid }

  constructor TGameGrid.Create( AParent : TControl; ARows, ACols : Integer; ATileSize : Single );
    begin
      FParentControl := AParent;
      FRows          := ARows;
      FCols          := ACols;
      FTileSize      := ATileSize;
      FGridTiles     := TObjectList< TGridTile >.Create( True ); // Owns objects
      CreateGrid;
    end;

  destructor TGameGrid.Destroy;
    begin
      FGridTiles.Free;
      inherited;
    end;

  procedure TGameGrid.CreateGrid;
    var
      Row      : Integer;
      Col      : Integer;
      Position : TPointF;
      Tile     : TGridTile;
    begin
      // Create the grid tiles
      FGridTiles.clear;
      for Row := 0 to FRows - 1 do
        begin
          for Col := 0 to FCols - 1 do
            begin
              Position := PointF( Col * FTileSize, Row * FTileSize );
              Tile     := TGridTile.Create( 'Ground', Position, FTileSize ); // Default to Grass
              FGridTiles.Add( Tile );
              FParentControl.AddObject( Tile.TileRect ); // Add tile to the parent visual control
            end;
        end;
    end;

  function TGameGrid.GetTileType( X, Y : Integer ) : string;
    var
      TileIndex : Integer;
    begin
      TileIndex := ( Y * FCols ) + X;
      if ( TileIndex >= 0 ) and ( TileIndex < FGridTiles.Count )
      then
        begin
          Result := FGridTiles[ TileIndex ].TileType;
        end
      else
        begin
          Result := EmptyStr;
        end;
    end;

  procedure TGameGrid.RenderGrid;
    begin
      CreateGrid;
      // This function can be extended to handle re-rendering if the grid is dynamic
    end;

  procedure TGameGrid.UpdateTileType( X, Y : Integer; ATileType : string );
    var
      TileIndex : Integer;
    begin
      // Find the tile index in the list based on X, Y position
      TileIndex := ( Y * FCols ) + X;
      if ( TileIndex >= 0 ) and ( TileIndex < FGridTiles.Count )
      then
        begin
          FGridTiles[ TileIndex ].TileType           := ATileType;
          FGridTiles[ TileIndex ].TileRect.Fill.Kind := TBrushKind.Solid; // Set to solid color

          // Update the tile's appearance based on its new type
          if ATileType = 'Grass'
          then
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Green;
            end
          else if ATileType = 'Water'
          then
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Blue;
            end
          else if ATileType = 'Wall'
          then
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Black;
            end
          else if ATileType = 'Character'
          then
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Yellow;
            end
          else if ATileType = 'Room'
          then
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Red;
            end
          else if ATileType = 'Door'
          then
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Blue;
            end
          else if ATileType = 'Ground'
          then
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Tan;
            end
          else
            begin
              FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.White; // Default color for undefined tile types
            end;
        end;
    end;

end.
