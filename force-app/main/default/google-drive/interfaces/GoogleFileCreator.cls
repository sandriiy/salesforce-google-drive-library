/** 
 * The GoogleFileCreator classifies builders that create files on Google Drive,
 * including those that work with files and have a return type of an instance of that file.
*/
public interface GoogleFileCreator {
    GoogleFileEntity execute();
}