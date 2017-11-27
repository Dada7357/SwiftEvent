using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace PDFParser
{
    public class ObjectWrapper
    {
        public byte[] bytes;
        public String header;

        public ObjectWrapper() { }

        public ObjectWrapper(byte[] bytes, String header)
        {
            this.bytes = bytes;
            this.header = header;
        }
    }

    public class Objects
    {
        public const String CRLF = "\r\n";
       
        public static ObjectWrapper[] GetAllObjectBlobs(System.IO.MemoryStream source)
        {
            System.Collections.Generic.List<ObjectWrapper> objectBlobs = new System.Collections.Generic.List<ObjectWrapper>();
            System.IO.MemoryStream tempBlob;
            String sourceAsText;
            System.Text.ASCIIEncoding encoder = new System.Text.ASCIIEncoding();
            int startIndex = 0;
            int lastIndex = 0;
            int blobLength = 0;
            String lengthText = "";
            byte[] buffer;
            int bytesRead = 0;
            String header = "";
            
            sourceAsText = encoder.GetString(source.ToArray());

            while (true)
            {
                //There is no more so exit.
                if (lastIndex < 0) break;

                startIndex = sourceAsText.IndexOf("obj", lastIndex) + "obj".Length ;
                if (startIndex == -1) break;

                //Adjust the start to the first of the header
                if (sourceAsText.IndexOf("<<", lastIndex) >-1) startIndex = sourceAsText.IndexOf("<<", lastIndex);

                //Get the header
                header = sourceAsText.Substring(startIndex, sourceAsText.IndexOf(CRLF, startIndex) - startIndex).Trim();

                //Find the length
                lengthText = Regex.Match(header,"/Length [0-9]+/").Value;
                if (lengthText.Length > 0)
                {
                    //Remove the word length
                    blobLength = int.Parse(Regex.Replace(lengthText, "[^0-9]", ""));
                    //Move the start index to where the endof the line is.
                    startIndex = sourceAsText.IndexOf("stream", startIndex) + "stream".Length + CRLF.Length;
                    lastIndex = sourceAsText.IndexOf("endstream", startIndex) - "endstream".Length + CRLF.Length;

                    tempBlob = new System.IO.MemoryStream();
                    source.Position = startIndex;
                    buffer = new byte[blobLength];
                    bytesRead = source.Read(buffer,  0,  buffer.Length);
                    tempBlob.Write(buffer, 0, bytesRead);
                    objectBlobs.Add(new ObjectWrapper(tempBlob.ToArray(), header));
                }
                else
                {                    
                    lastIndex = sourceAsText.IndexOf("endobj", startIndex + header.Length) - "endobj".Length;
                    //Return an empty array since there is no stream
                    objectBlobs.Add(new ObjectWrapper(new byte[]{}, header));
                }

            }

            return objectBlobs.ToArray() ;
        }
    }
}
