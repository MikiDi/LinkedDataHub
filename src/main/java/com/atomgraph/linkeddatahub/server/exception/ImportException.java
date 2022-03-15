/**
 *  Copyright 2019 Martynas Jusevičius <martynas@atomgraph.com>
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
package com.atomgraph.linkeddatahub.server.exception;

import org.apache.jena.rdf.model.Model;

/**
 * Exception thrown when data import terminates unexpectedly.
 * 
 * @author Martynas Jusevičius {@literal <martynas@atomgraph.com>}
 */
public class ImportException extends RuntimeException
{
    
    private final Model model;
    
    /**
     * Constructs exception.
     * 
     * @param message error message
     * @param model import model
     */
    public ImportException(String message, Model model)
    {
        super(message);
        this.model = model;
    }
    
    /**
     * Returns the import model.
     * 
     * @return RDF model
     */
    public Model getModel()
    {
        return model;
    }
    
}
