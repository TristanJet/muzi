const std = @import("std");
const builtin = @import("builtin");
const util = @import("util.zig");
const term = @import("terminal.zig");
const win = @import("window.zig");
const log = util.log;
const mem = std.mem;
const fmt = std.fmt;
const proc = std.process;
const fs = std.fs;
const net = std.net;
const posix = std.posix;

const helpmsg =
    \\Usage: muzi [options]
    \\-H, --host <str>      MPD host (default: 127.0.0.1)
    \\-p, --port <u16>      MPD port (default: 6600)
    \\-h, --help            Print help
    \\-v, --version         Print version
    \\
;

const debugmsg = if (builtin.mode == .Debug)
    std.fmt.comptimePrint(
        \\Debug-only options:
        \\-e, --etty <{s}>       TTY device (/dev/pts/{{n}}) which stderr will write to, leave empty for default: /dev/tty
        \\                      This is useful for reading core dumps
        \\
        \\
        \\-l, --ltty <{s}>       TTY device to which util.log() will print, leave empty for no logs
        \\                      Linux default:    /dev/pts/1
        \\                      Macos default:    /dev/ttys001
        \\
    , .{ @typeName(util.T_NTTY), @typeName(util.T_NTTY) })
else
    "";

const no_mpd_msg: []const u8 =
    \\error:    No MPD server found at "{}.{}.{}.{}:{}"
    \\info:     You can pass in a host and port using the "--host" and "--port" cli options
    \\info:     You can use the -h argument to print the help message
    \\
;

const inv_arg_msg: []const u8 =
    \\error:    Invalid argument
    \\info:     Usage: muzi [options]
    \\info:     You can use the -h argument to print the help message
    \\
;

const inv_ipv4_msg: []const u8 =
    \\error:    Invalid {s}
    \\info:     You can use the -h argument to print the help message
    \\
;

const win_too_small: []const u8 =
    \\error:    Window size too small
    \\info:     Muzi requires a minimum width and height of {} and {} cells
    \\
;

const version = "1.1.1";

pub const OptionValues = struct {
    host: ?[4]u8,
    port: ?u16,
    help: bool,
    version: bool,
    etty: ?util.T_NTTY,
    ltty: ?util.T_NTTY,
};

pub fn handleArgs() !OptionValues {
    var arg_val = OptionValues{
        .host = null,
        .port = null,
        .help = false,
        .version = false,
        .etty = null,
        .ltty = null,
    };
    var args = proc.args();
    _ = args.skip();
    while (args.next()) |arg| {
        if (mem.eql(u8, arg, "-p") or mem.eql(u8, arg, "--port")) {
            const val = args.next() orelse return error.InvalidOption;
            const port = fmt.parseUnsigned(u16, val, 10) catch return InvalidIPv4Error.InvalidPort;
            arg_val.port = port;
        } else if (mem.eql(u8, arg, "-H") or mem.eql(u8, arg, "--host")) {
            const val = args.next() orelse return error.InvalidOption;
            arg_val.host = validIpv4(val) catch return InvalidIPv4Error.InvalidHost;
        } else if (mem.eql(u8, arg, "-h") or mem.eql(u8, arg, "--help")) {
            arg_val.help = true;
            if (builtin.mode == .Debug) {
                const tty = try getTty();
                defer tty.close();
                _ = try posix.writev(tty.handle, &.{ .{ .base = helpmsg, .len = helpmsg.len }, .{ .base = debugmsg, .len = debugmsg.len } });
            } else {
                try write(helpmsg[0..]);
            }
        } else if (mem.eql(u8, arg, "-v") or mem.eql(u8, arg, "--version")) {
            arg_val.version = true;
            try write(version[0..] ++ "\n");
        } else if (mem.eql(u8, arg, "-e") or mem.eql(u8, arg, "--etty")) {
            if (builtin.mode != .Debug) return error.InvalidOption;
            const val = args.next() orelse return error.InvalidOption;
            const tty = fmt.parseUnsigned(util.T_NTTY, val, 10) catch return error.InvalidOption;
            arg_val.etty = tty;
        } else if (mem.eql(u8, arg, "-l") or mem.eql(u8, arg, "--ltty")) {
            if (builtin.mode != .Debug) return error.InvalidOption;
            const val = args.next() orelse return error.InvalidOption;
            const tty = fmt.parseUnsigned(util.T_NTTY, val, 10) catch return error.InvalidOption;
            arg_val.ltty = tty;
        } else {
            return error.InvalidOption;
        }
    }

    return arg_val;
}

fn getTty() !fs.File {
    const file = try fs.cwd().openFile(
        "/dev/tty",
        .{ .mode = .write_only },
    );
    return file;
}

fn write(msg: []const u8) !void {
    const tty = try getTty();
    defer tty.close();
    _ = try posix.write(tty.handle, msg);
}

pub const InvalidIPv4Error = error{
    InvalidHost,
    InvalidPort,
};

fn validIpv4(sl: []const u8) ![4]u8 {
    var iter = mem.tokenizeScalar(u8, sl, '.');
    var addr: [4]u8 = undefined;
    var counter: u8 = 0;
    while (iter.next()) |i| : (counter += 1) {
        if (counter > 3) return error.Overflow;
        addr[counter] = try fmt.parseInt(u8, i, 10);
    }
    return addr;
}

test "validIp" {
    const str: []const u8 = "127.0.0.1";
    const addy = try validIpv4(str);
    try std.testing.expect(addy[0] == 127);
    try std.testing.expect(addy[3] == 1);
}

pub fn printInvArg() !void {
    try write(inv_arg_msg);
}

pub fn printMpdFail(allocator: mem.Allocator, host: ?[4]u8, port: ?u16) !void {
    const h: [4]u8 = host orelse .{ 127, 0, 0, 1 };
    const p: u16 = port orelse 6600;
    const msg = try fmt.allocPrint(allocator, no_mpd_msg, .{ h[0], h[1], h[2], h[3], p });
    try write(msg);
}

pub fn printInvIp4(allocator: mem.Allocator, e: InvalidIPv4Error) !void {
    const arg: []const u8 = switch (e) {
        InvalidIPv4Error.InvalidHost => "host",
        InvalidIPv4Error.InvalidPort => "port",
    };
    const msg: []const u8 = try fmt.allocPrint(allocator, inv_ipv4_msg, .{arg});
    try write(msg);
}

pub fn printWinSmall(allocator: mem.Allocator) !void {
    const msg: []const u8 = try fmt.allocPrint(allocator, win_too_small, .{ win.MIN_WIN_WIDTH, win.MIN_WIN_HEIGHT });
    try write(msg);
}
