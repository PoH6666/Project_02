unit CL_Grid;

interface

  uses
    System.SysUtils,
    System.Types,
    System.UITypes,
    System.Classes,
    System.Generics.Collections,
    FMX.Graphics,
    FMX.Types,
    FMX.Controls,
    FMX.Objects;

  type
    // A single grid tile, representing an element in the map
    TGridTile = class
      private
        FTileRect : TRectangle; // Visual representation of the tile
        FTileType : string; // Type of the tile (e.g., 'Grass', 'Water', 'Wall')
      public
        property TileRect : TRectangle read FTileRect;
        property TileType : string read FTileType write FTileType;
        constructor Create( ATileType : string; APosition : TPointF; ASize : Single );
    end;

    // The grid, consisting of multiple tiles
    TGameGrid = class( TObject )
      private
        FRows          : Integer; // Number of rows in the grid
        FCols          : Integer; // Number of columns in the grid
        FTileSize      : Single; // Size of each tile
        FGridTiles     : TObjectList< TGridTile >; // List of all grid tiles
        FParentControl : TControl; // Parent control to hold the grid (e.g., Form or a Panel)
      public
        procedure CreateGrid;
        constructor Create( AParent : TControl; ARows, ACols : Integer; ATileSize : Single );
        destructor Destroy; override;
        procedure RenderGrid; // Render the grid on the parent control
        procedure UpdateTileType( X, Y : Integer; ATileType : string ); // Update tile type at a specific grid position
        function GetTileType( X, Y : Integer ) : string;
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
      if ATileType = 'Floor'
      then
        FTileRect.Fill.Color := TAlphaColors.Grey
      else if ATileType = 'Wall'
      then
        FTileRect.Fill.Color := TAlphaColors.Black
      else if ATileType = 'Table'
      then
        FTileRect.Fill.Color := TAlphaColors.Orange
      else if ATileType = 'Teacher'
      then
        FTileRect.Fill.Color := TAlphaColors.Cyan
      else if ATileType = 'Door'
      then
        FTileRect.Fill.Color := TAlphaColors.Blue
      else if ATileType = 'Character'
      then
        FTileRect.Fill.Color := TAlphaColors.Yellow
      else
        FTileRect.Fill.Color := TAlphaColors.White; // Default color for unclassified tiles
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

  function TGameGrid.GetTileType( X, Y : Integer ) : string;
    var
      TileIndex : Integer;
    begin
      TileIndex := ( Y * FCols ) + X;
      if ( TileIndex >= 0 ) and ( TileIndex < FGridTiles.Count )
      then
        Result := FGridTiles[ TileIndex ].TileType
      else
        Result := '';
    end;

  procedure TGameGrid.CreateGrid;
    var
      Row, Col : Integer;
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
              Tile     := TGridTile.Create( 'Floor', Position, FTileSize ); // Default to Grass
              FGridTiles.Add( Tile );
              FParentControl.AddObject( Tile.TileRect ); // Add tile to the parent visual control
            end;
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
          if ATileType = 'Floor'
          then
            FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Grey
          else if ATileType = 'Table'
          then
            FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Orange
          else if ATileType = 'Wall'
          then
            FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Black
          else if ATileType = 'Teacher'
          then
            FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Cyan
          else if ATileType = 'Character'
          then
            FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Yellow
          else if ATileType = 'Door'
          then
            FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.Blue
          else
            FGridTiles[ TileIndex ].TileRect.Fill.Color := TAlphaColors.White; // Default color for undefined tile types
        end;
    end;

end.
