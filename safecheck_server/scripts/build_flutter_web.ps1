$ErrorActionPreference = 'Stop'

$clientId = [Environment]::GetEnvironmentVariable('SAFE_CHECK_GOOGLE_CLIENT_ID')
$webOrigin = [Environment]::GetEnvironmentVariable('SAFE_CHECK_WEB_ORIGIN')
if ([string]::IsNullOrWhiteSpace($webOrigin)) {
    $webOrigin = 'https://safecheck.serverpod.space'
}

$originUri = $null
if (-not [Uri]::TryCreate($webOrigin, [UriKind]::Absolute, [ref]$originUri) -or
    $originUri.Scheme -ne 'https' -or
    $originUri.IsLoopback -or
    $originUri.Host.EndsWith('.localhost', [StringComparison]::OrdinalIgnoreCase) -or
    -not [string]::IsNullOrWhiteSpace($originUri.UserInfo) -or
    [string]::IsNullOrWhiteSpace($originUri.Host) -or
    $originUri.GetLeftPart([UriPartial]::Authority) -cne $webOrigin) {
    throw 'SAFE_CHECK_WEB_ORIGIN must be a public HTTPS origin without a path or trailing slash.'
}

$redirectUri = $originUri.GetLeftPart([UriPartial]::Authority) + '/auth.html'

$serverDir = Split-Path -Parent $PSScriptRoot
$flutterDir = [IO.Path]::GetFullPath((Join-Path $serverDir '..\safecheck_flutter'))
$outputDir = [IO.Path]::GetFullPath((Join-Path $serverDir 'web\app'))

$flutterArguments = @('build', 'web', '--release', '--base-href', '/')
$flutterArguments += "--dart-define=GOOGLE_CLIENT_ID=$clientId"
# Readiness and the public client ID are discovered from the running server.
$flutterArguments += "--dart-define=GOOGLE_WEB_REDIRECT_URI=$redirectUri"

Push-Location $flutterDir
try {
    & flutter @flutterArguments
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter release web build failed with exit code $LASTEXITCODE."
    }

    $builtAuthCallback = Join-Path $flutterDir 'build\web\auth.html'
    if (-not (Test-Path -LiteralPath $builtAuthCallback -PathType Leaf)) {
        throw 'Flutter web build did not produce auth.html; refusing to package an incomplete callback route.'
    }

    if (Test-Path -LiteralPath $outputDir) {
        $expectedOutput = [IO.Path]::GetFullPath((Join-Path $serverDir 'web\app'))
        if ($outputDir -cne $expectedOutput -or
            -not $outputDir.StartsWith($serverDir + [IO.Path]::DirectorySeparatorChar)) {
            throw 'Refusing to replace a Flutter build outside the server web/app directory.'
        }
        Remove-Item -LiteralPath $outputDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    Copy-Item -Path (Join-Path $flutterDir 'build\web\*') `
        -Destination $outputDir -Recurse -Force
} finally {
    Pop-Location
}
