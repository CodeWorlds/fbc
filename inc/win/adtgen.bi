'' FreeBASIC binding for mingw-w64-v3.3.0

#pragma once

#include once "winapifamily.bi"

#define _ADTGEN_H
const AUDIT_TYPE_LEGACY = 1
const AUDIT_TYPE_WMI = 2

type _AUDIT_PARAM_TYPE as long
enum
	APT_None = 1
	APT_String
	APT_Ulong
	APT_Pointer
	APT_Sid
	APT_LogonId
	APT_ObjectTypeList
	APT_Luid
	APT_Guid
	APT_Time
	APT_Int64
	APT_IpAddress
	APT_LogonIdWithSid
end enum

type AUDIT_PARAM_TYPE as _AUDIT_PARAM_TYPE
const AP_ParamTypeBits = 8
#define AP_ParamTypeMask __MSABI_LONG(&hff)
#define AP_FormatHex (__MSABI_LONG(&h1) shl AP_ParamTypeBits)
#define AP_AccessMask (__MSABI_LONG(&h2) shl AP_ParamTypeBits)
#define AP_Filespec (__MSABI_LONG(&h1) shl AP_ParamTypeBits)
#define AP_SidAsLogonId (__MSABI_LONG(&h1) shl AP_ParamTypeBits)
#define AP_PrimaryLogonId (__MSABI_LONG(&h1) shl AP_ParamTypeBits)
#define AP_ClientLogonId (__MSABI_LONG(&h2) shl AP_ParamTypeBits)
#define ApExtractType(TypeFlags) cast(AUDIT_PARAM_TYPE, TypeFlags and AP_ParamTypeMask)
#define ApExtractFlags(TypeFlags) (TypeFlags and (not AP_ParamTypeMask))
const _AUTHZ_SS_MAXSIZE = 128
const APF_AuditFailure = &h0
const APF_AuditSuccess = &h1
#define APF_ValidFlags APF_AuditSuccess
const AUTHZ_ALLOW_MULTIPLE_SOURCE_INSTANCES = &h1
const AUTHZ_MIGRATED_LEGACY_PUBLISHER = &h2
const AUTHZ_AUDIT_INSTANCE_INFORMATION = &h2

type _AUDIT_OBJECT_TYPE
	ObjectType as GUID
	Flags as USHORT
	Level as USHORT
	AccessMask as ACCESS_MASK
end type

type AUDIT_OBJECT_TYPE as _AUDIT_OBJECT_TYPE
type PAUDIT_OBJECT_TYPE as _AUDIT_OBJECT_TYPE ptr

type _AUDIT_OBJECT_TYPES
	Count as USHORT
	Flags as USHORT
	pObjectTypes as AUDIT_OBJECT_TYPE ptr
end type

type AUDIT_OBJECT_TYPES as _AUDIT_OBJECT_TYPES
type PAUDIT_OBJECT_TYPES as _AUDIT_OBJECT_TYPES ptr

type _AUDIT_IP_ADDRESS
	pIpAddress(0 to 127) as UBYTE
end type

type AUDIT_IP_ADDRESS as _AUDIT_IP_ADDRESS
type PAUDIT_IP_ADDRESS as _AUDIT_IP_ADDRESS ptr

type _AUDIT_PARAM
	as AUDIT_PARAM_TYPE Type
	Length as ULONG
	Flags as DWORD

	union
		Data0 as ULONG_PTR
		String as PWSTR
		u as ULONG_PTR
		psid as SID ptr
		pguid as GUID ptr
		LogonId_LowPart as ULONG
		pObjectTypes as AUDIT_OBJECT_TYPES ptr
		pIpAddress as AUDIT_IP_ADDRESS ptr
	end union

	union
		Data1 as ULONG_PTR
		LogonId_HighPart as LONG
	end union
end type

type AUDIT_PARAM as _AUDIT_PARAM
type PAUDIT_PARAM as _AUDIT_PARAM ptr

type _AUDIT_PARAMS
	Length as ULONG
	Flags as DWORD
	Count as USHORT
	Parameters as AUDIT_PARAM ptr
end type

type AUDIT_PARAMS as _AUDIT_PARAMS
type PAUDIT_PARAMS as _AUDIT_PARAMS ptr

type _AUTHZ_AUDIT_EVENT_TYPE_LEGACY
	CategoryId as USHORT
	AuditId as USHORT
	ParameterCount as USHORT
end type

type AUTHZ_AUDIT_EVENT_TYPE_LEGACY as _AUTHZ_AUDIT_EVENT_TYPE_LEGACY
type PAUTHZ_AUDIT_EVENT_TYPE_LEGACY as _AUTHZ_AUDIT_EVENT_TYPE_LEGACY ptr

union _AUTHZ_AUDIT_EVENT_TYPE_UNION
	Legacy as AUTHZ_AUDIT_EVENT_TYPE_LEGACY
end union

type AUTHZ_AUDIT_EVENT_TYPE_UNION as _AUTHZ_AUDIT_EVENT_TYPE_UNION
type PAUTHZ_AUDIT_EVENT_TYPE_UNION as _AUTHZ_AUDIT_EVENT_TYPE_UNION ptr

type _AUTHZ_AUDIT_EVENT_TYPE_OLD
	Version as ULONG
	dwFlags as DWORD
	RefCount as LONG
	hAudit as ULONG_PTR
	LinkId as LUID
	u as AUTHZ_AUDIT_EVENT_TYPE_UNION
end type

type AUTHZ_AUDIT_EVENT_TYPE_OLD as _AUTHZ_AUDIT_EVENT_TYPE_OLD
type PAUTHZ_AUDIT_EVENT_TYPE_OLD as AUTHZ_AUDIT_EVENT_TYPE_OLD ptr
const AUTHZP_WPD_EVENT = &h10
type AUDIT_HANDLE as PVOID
type PAUDIT_HANDLE as PVOID ptr