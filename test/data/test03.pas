unit test03;

interface

uses
  System.SysUtils;

implementation

function TSQLRestStorageMongoDB.EngineUpdateField(TableModelIndex: integer;
  const SetFieldName, SetValue, WhereFieldName, WhereValue: RawUTF8): boolean;
var JSON: RawUTF8;
    query,update: variant; // use explicit TBSONVariant for type safety
    id: TBSONIterator;
begin
  if (fCollection=nil) or (TableModelIndex<0) or
     (fModel.Tables[TableModelIndex]<>fStoredClass) or
     (SetFieldName='') or (SetValue='') or (WhereFieldName='') or (WhereValue='') then
    result := false else
    try // use {%:%} here since WhereValue/SetValue are already JSON encoded
      query := BSONVariant('{%:%}',[fStoredClassMapping^.InternalToExternal(
        WhereFieldName),WhereValue],[]);
      update := BSONVariant('{$set:{%:%}}',[fStoredClassMapping^.InternalToExternal(
        SetFieldName),SetValue],[]);
      fCollection.Update(query,update);
      if Owner<>nil then begin
        if Owner.InternalUpdateEventNeeded(TableModelIndex) and
           id.Init(fCollection.FindBSON(query,BSONVariant(['_id',1]))) then begin
          JSONEncodeNameSQLValue(SetFieldName,SetValue,JSON);
          while id.Next do
            Owner.InternalUpdateEvent(seUpdate,TableModelIndex,
              id.Item.DocItemToInteger('_id'),JSON,nil);
        end;
        Owner.FlushInternalDBCache;
      end;
      result := true;
    except
      result := false;
    end;
end;


end.
