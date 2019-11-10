Param(
  [Parameter(Mandatory)]
  [string] $Path,
  [ValidateSet("Foundational (100)","Intermediate (200)","Advanced (300)","Expert (400)")]
  [string[]] $Level = @(),
  [ValidateNotNullOrEmpty()]
  [string] $Product = "*",
  [int] $AttendeeCount = 0,
  [ValidateNotNullOrEmpty()]
  [string] $SessionType = "*"
)

$SessionsInfo = Invoke-RestMethod -Uri "https://api-myignite.techcommunity.microsoft.com/api/session/all" | Where-Object -FilterScript {$_.products -like "*$Product*"} | Where-Object -FilterScript { $_.attendeeCount -GE $AttendeeCount} | Where-Object -Property sessionType -Like $sessionType

if($Level.Count -gt 0) {
  $SessionsInfo = $SessionsInfo | Where-Object -FilterScript {$Level -eq $_.level}
}

$SessionsInfo | ForEach-Object -Process {
  $BaseName = "{0} - {1}" -f $_.sessionCode, [System.Text.RegularExpressions.Regex]::Replace($_.title,"[\\/:*?""<>|]","")

  if($_.downloadVideoLink) {
    if(!(Test-Path -Path "$Path\$BaseName.mp4")) {
      Invoke-WebRequest -Uri $_.downloadVideoLink -OutFile "$Path\$BaseName.mp4"
    }
  }

  if($_.slideDeck) {
    if(!(Test-Path -Path "$Path\$BaseName.pptx")) {
      Invoke-WebRequest -Uri $_.slideDeck -OutFile "$Path\$BaseName.pptx"
    }
  }
}