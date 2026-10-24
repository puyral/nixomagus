
import dbus
import dbus.mainloop.glib
import dbus.service
from gi.repository import GLib

AGENT_IFACE = "org.bluez.Agent1"
AGENT_PATH = "/org/bluez/AutoSinkAgent"


def set_trusted(bus, device_path):
    props = dbus.Interface(
        bus.get_object("org.bluez", device_path),
        "org.freedesktop.DBus.Properties",
    )
    props.Set("org.bluez.Device1", "Trusted", dbus.Boolean(True))


def setup_adapter(bus):
    om = dbus.Interface(
        bus.get_object("org.bluez", "/"),
        "org.freedesktop.DBus.ObjectManager",
    )
    for path, ifaces in om.GetManagedObjects().items():
        if "org.bluez.Adapter1" in ifaces:
            props = dbus.Interface(
                bus.get_object("org.bluez", path),
                "org.freedesktop.DBus.Properties",
            )
            props.Set("org.bluez.Adapter1", "Powered", dbus.Boolean(True))
            props.Set("org.bluez.Adapter1", "DiscoverableTimeout", dbus.UInt32(0))
            props.Set("org.bluez.Adapter1", "PairableTimeout", dbus.UInt32(0))
            props.Set("org.bluez.Adapter1", "Discoverable", dbus.Boolean(True))
            props.Set("org.bluez.Adapter1", "Pairable", dbus.Boolean(True))


class AutoAgent(dbus.service.Object):
    @dbus.service.method(AGENT_IFACE, in_signature="", out_signature="")
    def Release(self):
        pass

    @dbus.service.method(AGENT_IFACE, in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid):
        set_trusted(self.connection, device)

    @dbus.service.method(AGENT_IFACE, in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        set_trusted(self.connection, device)

    @dbus.service.method(AGENT_IFACE, in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        set_trusted(self.connection, device)

    @dbus.service.method(AGENT_IFACE, in_signature="o", out_signature="u")
    def RequestPasskey(self, device):
        set_trusted(self.connection, device)
        return dbus.UInt32(0)

    @dbus.service.method(AGENT_IFACE, in_signature="o", out_signature="s")
    def RequestPinCode(self, device):
        set_trusted(self.connection, device)
        return "0000"

    @dbus.service.method(AGENT_IFACE, in_signature="", out_signature="")
    def Cancel(self):
        pass


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    setup_adapter(bus)
    AutoAgent(bus, AGENT_PATH)
    manager = dbus.Interface(
        bus.get_object("org.bluez", "/org/bluez"),
        "org.bluez.AgentManager1",
    )
    manager.RegisterAgent(AGENT_PATH, "NoInputNoOutput")
    manager.RequestDefaultAgent(AGENT_PATH)
    GLib.MainLoop().run()


if __name__ == "__main__":
    main()
