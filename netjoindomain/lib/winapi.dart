import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

const NETSETUP_JOIN_DOMAIN = 0x00000001;
const NETSETUP_ACCT_CREATE = 0x00000002;
const NETSETUP_ACCT_DELETE = 0x00000004;
const NETSETUP_WIN9X_UPGRADE = 0x00000010;
const NETSETUP_DOMAIN_JOIN_IF_JOINED = 0x00000020;
const NETSETUP_JOIN_UNSECURE = 0x00000040;
const NETSETUP_MACHINE_PWD_PASSED = 0x00000080;
const NETSETUP_DEFER_SPN_SET = 0x00001000;
const NETSETUP_JOIN_WITH_NEW_NAME = 0x00000200;
const NETSETUP_DC_ACCOUNT = 0x00000400;
const NETSETUP_JOIN_READONLY = 0x00000800;
const NETSETUP_AMBIUOS_DC = 0x00001000;
const NETSETUP_NO_NETLOGON_CACHE = 0x00002000;
const NETSETUP_DONT_CONTROL_SERVICES = 0x00004000;
const NETSETUP_SET_MACHINE_NAME = 0x00008000;
const NETSETUP_FORCE_SPN_SET = 0x0001000;
const NETSETUP_NO_ACCT_REUSE = 0x0002000;
const NETSETUP_IGNORE_UNSUPPORTED_FLAGS = 0x100000000;

const NERR_Success = 0;

const ERROR_ACCESS_DENIED = 5;
const ERROR_INVALID_PASSWORD = 86;
const ERROR_WRONG_PASSWORD = 1323;

const ERROR_INVALID_DOMAIN_ROLE = 1354;
const ERROR_NO_SUCH_DOMAIN = 1355;
const ERROR_DOMAIN_CONTROLLER_NOT_FOUND = 2453;

const ERROR_NO_LOGON_SERVERS = 1311;
const ERROR_NOT_SUPPORTED = 50;
const ERROR_BAD_NETPATH = 53;
const ERROR_INVALID_PARAMETER = 87;
const ERROR_INVALID_COMPUTERNAME = 1210;
const ERROR_DOMAIN_EXISTS = 1250;
const ERROR_DS_MACHINE_ACCOUNT_QUOTA_EXCEEDED = 8557;
const ERROR_DNS_INVALID_CHAR = 9560;

const ERROR_NETLOGON_NOT_STARTED = 1792;
const ERROR_NETWORK_UNREACHABLE = 1231;

final _netapi32 = DynamicLibrary.open('netapi32.dll');

int NetJoinDomain(
        Pointer<Utf16> lpServer,
        Pointer<Utf16> lpDomain,
        Pointer<Utf16> lpMachineAccountOU,
        Pointer<Utf16> lpAccount,
        Pointer<Utf16> lpPassword,
        int fJoinOptions) =>
    _NetJoinDomain(lpServer, lpDomain, lpMachineAccountOU, lpAccount,
        lpPassword, fJoinOptions);

final _NetJoinDomain = _netapi32.lookupFunction<
    Uint32 Function(
        Pointer<Utf16> lpServer,
        Pointer<Utf16> lpDomain,
        Pointer<Utf16> lpMachineAccountOU,
        Pointer<Utf16> lpAccount,
        Pointer<Utf16> lpPassword,
        Uint32 fJoinOptions),
    int Function(
        Pointer<Utf16> lpServer,
        Pointer<Utf16> lpDomain,
        Pointer<Utf16> lpMachineAccountOU,
        Pointer<Utf16> lpAccount,
        Pointer<Utf16> lpPassword,
        int fJoinOptions)>('NetJoinDomain');

int NetUnjoinDomain(Pointer<Utf16> lpServer, Pointer<Utf16> lpAccount,
        Pointer<Utf16> lpPassword, int fUnjoinOptions) =>
    _NetUnjoinDomain(lpServer, lpAccount, lpPassword, fUnjoinOptions);

final _NetUnjoinDomain = _netapi32.lookupFunction<
    Uint32 Function(Pointer<Utf16> lpServer, Pointer<Utf16> lpAccount,
        Pointer<Utf16> lpPassword, Uint32 fUnjoinOptions),
    int Function(Pointer<Utf16> lpServer, Pointer<Utf16> lpAccount,
        Pointer<Utf16> lpPassword, int fUnjoinOptions)>('NetUnjoinDomain');
