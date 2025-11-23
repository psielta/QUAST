unit UAuthUtils;

interface

uses
  System.SysUtils, System.Hash;

function HashPassword(const APlain: string): string;
function VerifyPassword(const APlain, AHash: string): Boolean;

implementation

function HashPassword(const APlain: string): string;
begin
  // SHA-256 hexadecimal upper-case
  Result := THashSHA2.GetHashString(APlain);
end;

function VerifyPassword(const APlain, AHash: string): Boolean;
begin
  Result := SameText(HashPassword(APlain), AHash);
end;

end.
