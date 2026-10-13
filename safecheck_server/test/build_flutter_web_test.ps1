$ErrorActionPreference = 'Stop'
$buildScript = Join-Path $PSScriptRoot '..\scripts\build_flutter_web.ps1'

# Intercept the compiler and stop before packaging. No SDK, network or output
# directory is touched by these argument/validation tests.
$global:safeCheckCapturedFlutterArgs = @()
function flutter {
    $global:safeCheckCapturedFlutterArgs = @($args)
    $global:LASTEXITCODE = 7
}

$env:SAFE_CHECK_GOOGLE_CLIENT_ID = ''
$env:SAFE_CHECK_WEB_ORIGIN = ''
try {
    & $buildScript
    throw 'Expected the fake compiler failure to stop packaging.'
} catch {
    if ($_.Exception.Message -ne 'Flutter release web build failed with exit code 7.') {
        throw
    }
}
if ($global:safeCheckCapturedFlutterArgs -notcontains '--release' -or
    $global:safeCheckCapturedFlutterArgs -notcontains '--dart-define=GOOGLE_WEB_REDIRECT_URI=https://safecheck.serverpod.space/auth.html' -or
    $global:safeCheckCapturedFlutterArgs -notcontains '--dart-define=GOOGLE_CLIENT_ID=') {
    throw 'Release defaults must keep the production callback and allow runtime client-ID discovery.'
}
if ($global:safeCheckCapturedFlutterArgs -contains '--dart-define=GOOGLE_IDP_CONFIGURED=true') {
    throw 'Build arguments cannot promise that server-side Google is configured.'
}
'PASS: default release callback and runtime readiness'

foreach ($unsafeOrigin in @('https://localhost', 'https://app.localhost', 'https://127.0.0.1', 'http://safecheck.serverpod.space', 'https://safecheck.serverpod.space/', 'https://user@safecheck.serverpod.space')) {
    $env:SAFE_CHECK_WEB_ORIGIN = $unsafeOrigin
    $global:safeCheckCapturedFlutterArgs = @()
    try {
        & $buildScript
        throw 'Expected origin validation to fail before compiling.'
    } catch {
        if ($_.Exception.Message -ne 'SAFE_CHECK_WEB_ORIGIN must be a public HTTPS origin without a path or trailing slash.') {
            throw
        }
    }
    if ($global:safeCheckCapturedFlutterArgs.Count -gt 0) {
        throw 'Unsafe origin reached the compiler.'
    }
}
'PASS: unsafe origins rejected before compilation'
