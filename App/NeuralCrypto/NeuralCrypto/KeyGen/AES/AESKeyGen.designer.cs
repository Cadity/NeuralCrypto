// WARNING
//
// This file has been generated automatically by Visual Studio to store outlets and
// actions made in the UI designer. If it is removed, they will be lost.
// Manual changes to this file may not be handled correctly.
//
using Foundation;
using System.CodeDom.Compiler;

namespace NeuralCrypto.KeyGen
{
	[Register ("AESKeyGen")]
	partial class AESKeyGen
	{
		[Outlet]
		AppKit.NSTextField EntryBloc { get; set; }

		[Outlet]
		AppKit.NSTextField IV { get; set; }

		[Outlet]
		AppKit.NSPopUpButton KeySizeOutlet { get; set; }

		[Action ("KeySizeButton:")]
		partial void KeySizeButton (Foundation.NSObject sender);
		
		void ReleaseDesignerOutlets ()
		{
			if (KeySizeOutlet != null) {
				KeySizeOutlet.Dispose ();
				KeySizeOutlet = null;
			}

			if (EntryBloc != null) {
				EntryBloc.Dispose ();
				EntryBloc = null;
			}

			if (IV != null) {
				IV.Dispose ();
				IV = null;
			}
		}
	}
}
