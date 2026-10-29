param(
    [string]$ProbeRs  = "${PSScriptRoot}/../tools/probe-rs/probe-rs.exe",
    [string]$HexFile  = "${PSScriptRoot}/../build/projects/projects.hex",
    [string]$Chip     = "CIU32F003F5Px",
    [string]$Probe    = "0d28:0204",
    [ValidateRange(1, 50000)]
    [int]$Speed       = 5000
)

Write-Host ""
Write-Host "=========================================="
Write-Host "  F8 Flash CIU32F003 + PWLINK2lite"
Write-Host "=========================================="

if (-not (Test-Path -LiteralPath $ProbeRs -PathType Leaf)) {
    Write-Error "Not found probe-rs: $ProbeRs"
    exit 1
}
if (-not (Test-Path -LiteralPath $HexFile -PathType Leaf)) {
    Write-Error "Not found firmware file: $HexFile"
    exit 1
}

# Step 0: check debugger occupation
Write-Host ""
Write-Host "[0/3] Check debugger occupation..."

$conflicts = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match "PowerWriter|OpenOCD" })

if ($conflicts.Count -gt 0) {
    Write-Host "      WARNING: possible debugger occupation processes detected:"
    foreach ($p in $conflicts) {
        Write-Host "          $($p.ProcessName) (PID=$($p.Id))"
    }
    Write-Host ""
    Write-Error "Please close above programs first, then re-run flash task."
    exit 1
} else {
    Write-Host "      OK: debugger idle (PWLINK2lite available)"
}

# Step 1: full chip erase
Write-Host ""
Write-Host "[1/3] Full chip erase (SWD $($Speed) kHz)..."
& $ProbeRs erase --chip $Chip --probe $Probe --protocol swd --speed $Speed --non-interactive --disable-progressbars
if ($LASTEXITCODE -ne 0) {
    Write-Host "      FAIL: erase failed (exit=$LASTEXITCODE)"
    Write-Host "      Hint: SWD wires not connected / chip locked"
    exit $LASTEXITCODE
}
Write-Host "      OK: full chip erase done"

# Step 2: download .hex + verify
Write-Host ""
Write-Host "[2/3] Download .hex + verify (SWD $($Speed) kHz)..."
& $ProbeRs download $HexFile --chip $Chip --probe $Probe --protocol swd --speed $Speed --binary-format ihex --verify --non-interactive --disable-progressbars
if ($LASTEXITCODE -ne 0) {
    Write-Host "      FAIL: flash failed (exit=$LASTEXITCODE)"
    exit $LASTEXITCODE
}
Write-Host "      OK: flash+verify passed"

# Step 3: reset and run
Write-Host ""
Write-Host "[3/3] Reset and start firmware (SWD $($Speed) kHz)..."
& $ProbeRs reset --chip $Chip --probe $Probe --protocol swd --speed $Speed --non-interactive
if ($LASTEXITCODE -ne 0) {
    Write-Host "      WARN: reset failed (exit=$LASTEXITCODE)"
} else {
    Write-Host "      OK: firmware started"
}

Write-Host ""
Write-Host "=========================================="
Write-Host "  OK: Flash completed!"
Write-Host "=========================================="
exit 0