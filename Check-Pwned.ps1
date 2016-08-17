Param(
  [string]$SourcePath,
  [string]$DestinationPath
)

#import the emails from CSV
$content = Import-Csv -Path $SourcePath 

Foreach ($line in $content) {

    #trim the line breaks and any spaces
    $email = $line.email.Trim('`t`n`r')
    $first = $line.First.Trim('`t`n`r')
    $Last = $line.Last.Trim('`t`n`r')
    #set URL
    $url = "https://haveibeenpwned.com/api/breachedaccount/$email"
    #get http content from web
    try {
        Start-Sleep -Milliseconds 1500 #Sleeping to confirm ton Troy Hunt's future rate limit
        $account =  $request =  Invoke-WebRequest -Uri $url -ErrorAction Stop        
    #strip out the Services comprimsed
    $sites = $account.Content | ForEach-Object {
        $_ -replace '"', '' `
             -replace ']', '' `
             -replace '\[', '' `
            } 

     #split services into array
    $arrSites =  $sites.Split(",")

    #go through each line and add an row for each service
    Foreach ($site in $arrSites) {

        $csvContents = @() # Create the empty array that will eventually be the CSV file

        $row = New-Object System.Object # Create an object to append to the array
        $row | Add-Member -MemberType NoteProperty -Name "Email" -Value $email 
        $row | Add-Member -MemberType NoteProperty -Name "Site" -Value $site
        $row | Add-Member -MemberType NoteProperty -Name "First Name" -Value $first
        $row | Add-Member -MemberType NoteProperty -Name "Last Name" -Value $Last

        $csvContents += $row # append the new data to the array
        
        #export to CSV
        $csvContents | Export-Csv -Path $DestinationPath -Append
        
        }

    }

    catch {
        #nothing here    
    }
   
}






