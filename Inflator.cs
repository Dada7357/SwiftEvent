using System.Text;
using ICSharpCode.SharpZipLib.Zip.Compression.Streams;

namespace PDFParser
{
    public class Inflator
    {
        public static System.String FlateDecodeToASCII(System.IO.MemoryStream source)
        {
            System.Text.ASCIIEncoding encoder = new System.Text.ASCIIEncoding();

            return encoder.GetString( FlateDecode(source));        
        }

        public static byte[] FlateDecode(System.IO.MemoryStream source)
        {
            byte[] buffer = new byte[4091];
            int bytesRead = 0;
            InflaterInputStream sharpZipLibInflator;
            System.IO.MemoryStream returnStream = new System.IO.MemoryStream();

            source.Position = 0;
            sharpZipLibInflator = new InflaterInputStream(source);

            while (true)
            {
                bytesRead = sharpZipLibInflator.Read(buffer, 0, buffer.Length);
                if (bytesRead == 0) break;
                returnStream.Write(buffer, 0, bytesRead); 
            }
            return returnStream.ToArray(); 
        }
    }
}
