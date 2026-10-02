namespace Mc2it.Hcon

open Microsoft.PowerShell.Commands
open System.Linq
open System.Management.Automation
open System.Text.RegularExpressions

/// Converts a HCON-formatted string to a hash table.
[<Cmdlet(VerbsData.ConvertFrom, "Hcon")>]
[<OutputType(typeof<OrderedHashtable>)>]
type ConvertFromHconCommand() =
  inherit Cmdlet()

  /// The pattern used to tokenize HCON-formatted strings.
  static let hconPattern = Regex @"(?:""([^""]+)""|'([^']+)'|([^\s,:]+))(?:\s*:\s*(?:""([^""]*)""|'([^']*)'|<((?:[^/]|\/(?!>))+)\/>|([^\s,]+)))?(?=\s|,|$)"

  let mergeHashtables () =
    ()

  /// The HCON-formatted string to convert.
  [<Parameter; ValidateRange(ValidateRangeKind.Positive)>]
  member val Depth = 1024 with get, set

  /// The HCON-formatted string to convert.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true); AllowEmptyString>]
  member val InputObject = "" with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let hcon = this.InputObject.Trim()
    if hcon.Length = 0 then
      this.WriteObject (OrderedHashtable())
    elif hcon[0] = '{' then
      let json = ConvertFromJsonCommand(InputObject = hcon, AsHashtable = true, Depth = this.Depth)
      json.Invoke<OrderedHashtable>() |> Seq.head |> this.WriteObject
    else
      let getGroup (hconMatch: Match) (index: int): string option =
        let value = hconMatch.Groups[index].Value
        if value.Length > 0 then Some value else None

      let hashtable = OrderedHashtable()
      for hconMatch in hconPattern.Matches hcon do
        let doubleQuotedKey = getGroup hconMatch 1 // "key"
        let singleQuotedKey = getGroup hconMatch 2 // 'key'
        let bareKey = getGroup hconMatch 3 |> Option.toObj |> nonNull // key
        let doubleQuotedValue = getGroup hconMatch 4 // "value"
        let singleQuotedValue = getGroup hconMatch 5 // 'value'
        let hyperscriptValue = getGroup hconMatch 6 // <value/>
        let bareValue = getGroup hconMatch 7 // value

        let key =
          doubleQuotedKey
          |> Option.orElse singleQuotedKey
          |> Option.defaultValue bareKey

        let value =
          doubleQuotedValue
          |> Option.orElse singleQuotedValue
          |> Option.orElse hyperscriptValue
          |> Option.orElse bareValue
          |> Option.defaultValue "true"
          |> _.Trim()

        // try { value = ConvertFrom-Json value -AsHashtable -Depth Depth -ErrorAction Stop } catch {}

        if not (bareKey.Contains '.') then
          // mergeHashtables @{ key = value } hashtable
          ()
        else
          let pair = value
          let segments = key.Split '.'
          // mergeHashtables pair hashtable
          ()

        // if (bareKey -notlike "*.*") { Merge-HconHashtable @{ key = value } hashtable }
        // else {
        //   pair = value
        //   segments = key -split "\."
        //   foreach (index in (segments.Count - 1)..0) { pair = @{ segments[index] = pair } }
        //   Merge-HconHashtable pair hashtable
        // }

      this.WriteObject hashtable
