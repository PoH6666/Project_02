unit Pathfinding;

interface

  uses
    // Windows Units
    // Delphi Units
    System.Classes,
    System.Generics.Collections,
    System.Types,
    // SIVille Units
    uGameGrid;

  type
    TPathNode = class
      GCost : Integer;
      HCost : Integer;
      FCost : Integer; // A* costs
      Parent : TPathNode; // Pointer to parent node for path reconstruction
      X : Integer; // XPosition in the grid
      Y : Integer; // Y Position in the grid
      constructor Create( AX, AY : Integer; AParent : TPathNode = nil );
    end;

    TPathfinding = class
      private
        FGameGrid : TGameGrid;
        FRows     : Integer;
        FCols     : Integer; // Grid dimensions
        function CalculateHCost( StartX, StartY, EndX, EndY : Integer ) : Integer;
        function GetNeighbors( Node : TPathNode ) : TList< TPathNode >;
        function IsWalkable( X, Y : Integer ) : Boolean;
      public
        constructor Create( AGameGrid : TGameGrid; ARows, ACols : Integer );
        function FindPath( StartX, StartY, EndX, EndY : Integer ) : TList< TPoint >;
    end;

implementation

  { TPathNode }

  constructor TPathNode.Create( AX, AY : Integer; AParent : TPathNode );
    begin
      X      := AX;
      Y      := AY;
      Parent := AParent;
      GCost  := 0;
      HCost  := 0;
      FCost  := 0;
    end;

  { TPathfinding }

  constructor TPathfinding.Create( AGameGrid : TGameGrid; ARows, ACols : Integer );
    begin
      FGameGrid := AGameGrid;
      FRows     := ARows;
      FCols     := ACols;
    end;

  function TPathfinding.CalculateHCost( StartX, StartY, EndX, EndY : Integer ) : Integer;
    begin
      // Use Manhattan distance for grid-based movement
      Result := Abs( EndX - StartX ) + Abs( EndY - StartY );
    end;

  function TPathfinding.FindPath( StartX, StartY, EndX, EndY : Integer ) : TList< TPoint >;
    var
      OpenList     : TList< TPathNode >;
      ClosedList   : TList< TPathNode >;
      CurrentNode  : TPathNode;
      Neighbor     : TPathNode;
      Path         : TList< TPoint >;
      LowestFNode  : TPathNode;
      NeighborNode : TPathNode;
    begin
      OpenList   := TList< TPathNode >.Create;
      ClosedList := TList< TPathNode >.Create;
      Path       := TList< TPoint >.Create;
      try
        OpenList.Add( TPathNode.Create( StartX, StartY ) );

        while OpenList.Count > 0 do
          begin
            // Get node with lowest FCost
            LowestFNode := OpenList.First;
            for CurrentNode in OpenList do
              if ( CurrentNode.FCost < LowestFNode.FCost ) or
                ( ( CurrentNode.FCost = LowestFNode.FCost ) and ( CurrentNode.HCost < LowestFNode.HCost ) )
              then
                begin
                  LowestFNode := CurrentNode;
                end;

            CurrentNode := LowestFNode;
            OpenList.Remove( CurrentNode );
            ClosedList.Add( CurrentNode );

            // Check if endpoint is reached
            if ( CurrentNode.X = EndX ) and ( CurrentNode.Y = EndY )
            then
              begin
                while Assigned( CurrentNode ) do
                  begin
                    Path.Insert( 0, TPoint.Create( CurrentNode.X, CurrentNode.Y ) );
                    CurrentNode := CurrentNode.Parent;
                  end;
                Exit( Path );
              end;

            // Process neighbors
            for Neighbor in GetNeighbors( CurrentNode ) do
              begin
                if ClosedList.Contains( Neighbor )
                then
                  begin
                    Continue;
                  end;

                Neighbor.GCost := CurrentNode.GCost + 1;
                Neighbor.HCost := CalculateHCost( Neighbor.X, Neighbor.Y, EndX, EndY );
                Neighbor.FCost := Neighbor.GCost + Neighbor.HCost;

                // Add to open list if not already present
                if not OpenList.Contains( Neighbor )
                then
                  begin
                    OpenList.Add( Neighbor );
                  end;
              end;
          end;

        Result := Path; // Return empty path if no route is found
      finally
        OpenList.Free;
        ClosedList.Free;
      end;
    end;

  function TPathfinding.GetNeighbors( Node : TPathNode ) : TList< TPathNode >;
    const
      Directions : array [ 0 .. 3 ] of TPoint = ( ( X : 0; Y : - 1 ), ( X : 1; Y : 0 ), ( X : 0; Y : 1 ), ( X : - 1; Y : 0 ) );
    var
      Dir                  : TPoint;
      NeighborX, NeighborY : Integer;
      Neighbor             : TPathNode;
    begin
      Result := TList< TPathNode >.Create;

      for Dir in Directions do
        begin
          NeighborX := Node.X + Dir.X;
          NeighborY := Node.Y + Dir.Y;

          if IsWalkable( NeighborX, NeighborY )
          then
            begin
              Neighbor := TPathNode.Create( NeighborX, NeighborY, Node );
              Result.Add( Neighbor );
            end;
        end;
    end;

  function TPathfinding.IsWalkable( X, Y : Integer ) : Boolean;
    begin
      Result := ( X >= 0 ) and ( Y >= 0 ) and ( X < FCols ) and ( Y < FRows ) and ( FGameGrid.GetTileType( X, Y ) <> 'Wall' );
    end;

end.
